; docformat = 'rst'

;+
; Make an engineering plot of the flat values.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region, i.e., '1074'
;   flat_times : in, required, type=fltarr(n_flats)
;     array of times of the flats in hours into the observing day
;   flat_exposures : in, required, type=fltarr(n_flats)
;     array of exposure times of the flats
;   flat_wavelengths : in, required, type=fltarr(n_flats)
;     array of wavelengths of the flats
;   flat_gain_modes : in, required, type=strarr(n_flats)
;     array of gain modes of the flats, 'high' or 'low'
;   flat_onbands : in, required, type=intarr(n_flats)
;     array of ONBAND values: 0 for RCAM, 1 for TCAM
;   flat_nucs : in, required, type=lonarr(n_flats)
;     array of indices of NUC values
;   flat_data : in, required, type="fltarr(nx, ny, n_cameras, n_extensions)"
;     array of ONBAND values: 0 for RCAM, 1 for TCAM
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_flat_plots, wave_region, $
                      flat_times, $
                      flat_exposures, $
                      flat_wavelengths, $
                      flat_gain_modes, $
                      flat_onbands, $
                      flat_nucs, $
                      flat_data, $
                      run=run
  compile_opt strictarr

  mg_log, 'making flat plots for %s nm', wave_region, $
          name=run.logger_name, /info

  n_flats = n_elements(flat_times)
  if (n_flats eq 0L) then begin
    mg_log, 'no flats to plot', name=run.logger_name, /info
    goto, done
  endif

  ; dark correct flats
  cal = run.calibration
  dark_corrected_flat_data = flat_data
  for f = 0L, n_flats - 1L do begin
    flat_dark = cal->get_dark(flat_times[f], $
                              flat_exposures[f], $
                              flat_gain_modes[f] ? 'high' : 'low', $
                              flat_nucs[f], $
                              found=flat_dark_found)
    if (flat_dark_found) then begin
      if (size(flat_dark, /n_dimensions) eq 4L) then flat_dark = flat_dark[*, *, *, 0]
      dark_corrected_flat_data[*, *, *, f] -= flat_dark
    endif else begin
      mg_log, 'dark not found for time %0.4f, exposure %0.1f, gain mode %s', $
              flat_times[f], $
              flat_exposures[f], $
              flat_gain_modes[f] ? 'high' : 'low', $
              name=run.logger_name, /debug
    endelse
  endfor

  unique_wavelength_indices = uniq(flat_wavelengths, sort(flat_wavelengths))
  n_unique_wavelengths = n_elements(unique_wavelength_indices)

  ; save original graphics settings
  original_device = !d.name

  ; setup graphics device
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=8, $
          set_resolution=[1600, n_unique_wavelengths * 250]

  tvlct, 0, 0, 0, 0
  tvlct, 255, 255, 255, 1
  tvlct, 255, 0, 0, 2
  tvlct, 0, 0, 255, 3
  tvlct, r, g, b, /get

  color            = 0
  background_color = 1
  camera_color     = [2, 3]

  camera_psym      = [6, 4]
  symsize          = 0.75

  charsize = 1.75

  ; use a horizontal dash for quartile values
  usersym, 2.0 * [-1.0, 1.0], fltarr(2)

  !null = ucomp_hours_format(/minutes)
  time_range = [16.0, 28.0]
  time_ticks = time_range[1] - time_range[0]

  flat_range = run->line(wave_region, 'flat_value_display_range')

  ; columns for ONBAND, rows for wavelengths
  !p.multi = [0, 2, n_unique_wavelengths]
  shown_legend = 0B

  for w = 0L, n_unique_wavelengths - 1L do begin
    for o = 0L, 1L do begin
      indices = where((flat_wavelengths eq flat_wavelengths[unique_wavelength_indices[w]]) $
                        and (flat_onbands eq o), $
                      count)

      plot, [flat_times + 10.0], findgen(n_elements(flat_times)), /nodata, $
            charsize=charsize, $
            title=string(flat_wavelengths[unique_wavelength_indices[w]], $
                         o ? 'TCAM' : 'RCAM', $
                         format='(%"Dark corrected flat median counts (+/- 1 std dev) for %0.3f nm (%s onband)")'), $
            color=color, background=background_color, $
            xtitle='Time [UT]', $
            xstyle=1, xrange=time_range, xticks=time_ticks, $
            xtickformat='ucomp_hours_format', $
            ytitle='Counts [DN]', $
            ystyle=1, yrange=flat_range, ytickformat='ucomp_dn_format'

      if (~shown_legend) then begin
        shown_legend = 1B
        xyouts, 0.47, (n_unique_wavelengths - 0.20) / n_unique_wavelengths, /normal, $
                'camera 0', alignment=1.0, color=camera_color[0]
        xyouts, 0.47, (n_unique_wavelengths - 0.25) / n_unique_wavelengths, /normal, $
                'camera 1', alignment=1.0, color=camera_color[1]
      endif

      if (count eq 0L) then continue

      for c = 0L, 1L do begin
        flat_medians = fltarr(count)
        flat_stddevs = fltarr(count)
        for f = 0L, count - 1L do begin
          flat_medians[f] = median(dark_corrected_flat_data[*, *, c, indices[f]])
          flat_stddevs[f] = stddev(dark_corrected_flat_data[*, *, c, indices[f]])
        endfor
        mg_range_oplot, [flat_times[indices] + 10.0], $
                        flat_range[0] > [flat_medians] < flat_range[1], $
                        psym=camera_psym[c], symsize=symsize, $
                        color=camera_color[c], $
                        clip_color=camera_color[c], clip_psym=7, clip_symsize=1.0
        mg_range_oplot, [flat_times[indices] + 10.0], $
                        flat_range[0] > [flat_medians - flat_stddevs] < flat_range[1], $
                        psym=8, symsize=0.5 * symsize, $
                        color=camera_color[c], $
                        clip_color=camera_color[c], clip_psym=7, clip_symsize=1.0
        mg_range_oplot, [flat_times[indices] + 10.0], $
                        flat_range[0] > [flat_medians + flat_stddevs] < flat_range[1], $
                        psym=8, symsize=0.5 * symsize, $
                        color=camera_color[c], $
                        clip_color=camera_color[c], clip_psym=7, clip_symsize=1.0
        for f = 0L, count - 1L do begin
          plots, (flat_times[indices])[f] + fltarr(3) + 10.0, $
                 flat_range[0] > (flat_medians[f] + [-1, 0, 1] * flat_stddevs[f]) < flat_range[1], $
                 linestyle=4, color=camera_color[c]
        endfor
      endfor
    endfor
  endfor

  ; save plots image file
  output_filename = filepath(string(run.date, wave_region, format='(%"%s.ucomp.%s.daily.flats.gif")'), $
                             subdir=ucomp_decompose_date(run.date), $
                             root=run->config('engineering/basedir'))
  write_gif, output_filename, tvrd(), r, g, b

  done:
  !p.multi = 0
  if (n_elements(original_rgb) gt 0L) then tvlct, original_rgb
  if (n_elements(original_decomposed) gt 0L) then device, decomposed=original_decomposed
  if (n_elements(original_device) gt 0L) then set_plot, original_device

  mg_log, 'done', name=run.logger_name, /info
end
