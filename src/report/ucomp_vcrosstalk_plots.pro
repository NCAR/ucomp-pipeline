; docformat = 'rst'

;+
; Make a V crosstalk plot for the given wave region.
;
; :Params:
;   date : in, required, type=string
;     date in the form "YYYYMMDD"
;   wave_region : in, required, type=string
;     wave region in the form "WWWW", i.e., "1074"
;   output_dir : in, required, type=string
;     directory to write the output image files
;   times : in, required, type=fltarr(n)
;     times of the V crosstalk readings in hours in the observing day
;   vcrosstalk : in, required, type=fltarr(n)
;     V crosstalk readings
;   max_value : in, optional, type=float, default=max(vcrosstalk)
;-
pro ucomp_vcrosstalk_plots_wave_region, date, $
                                        wave_region, $
                                        output_dir, $
                                        times, $
                                        vcrosstalk, $
                                        max_value=max_value
  compile_opt strictarr

  _max_value = mg_default(max_value, max(vcrosstalk))

  if (n_elements(wave_region) eq 0L) then begin
    basename = string(date, format='(%"%s.ucomp.daily.vcrosstalk.gif")')
    title = string(date, format='(%"V crosstalk on %s")')
  endif else begin
    basename = string(date, wave_region, format='(%"%s.ucomp.%s.daily.vcrosstalk.gif")')
    title = string(wave_region, date, format='(%"V crosstalk for %s nm on %s")')
  endelse
  filename = filepath(basename, root=output_dir)

  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, set_resolution=[600, 300], $
          decomposed=0, $
          set_colors=256, $
          z_buffering=0
  loadct, 0, /silent, ncolors=254
  tvlct, 255, 0, 0, 255
  tvlct, r, g, b, /get

  mg_range_plot, times, vcrosstalk, $
                 title=title, $
                 psym=6, symsize=0.25, color=0, background=254, $
                 clip_psym=6, clip_color=255, $
                 xtitle='Time [UT]', $
                 xstyle=1, xrange=[6.0, 18.0], xticks=12, $
                 xtickformat='ucomp_hours_format', $
                 ystyle=1, yrange=[0.0, _max_value], ytitle='V crosstalk'

  write_gif, filename, tvrd(), r, g, b

  done:
  tvlct, original_rgb
  device, decomposed=original_decomposed
  set_plot, original_device
end


;+
; Plot V crosstalk over time for each wave region.
;
; :Params:
;   output_dir : in, required, type=string
;     directory to write output files
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_vcrosstalk_plots, output_dir, run=run
  compile_opt strictarr

  wave_regions = run->config('options/wave_regions')
  for w = 0L, n_elements(wave_regions) - 1L do begin
    files = run->get_files(data_type='sci', $
                           wave_region=wave_regions[w], $
                           count=n_files)
    if (n_files gt 0L) then begin
      times = fltarr(n_files)
      vcrosstalk = fltarr(n_files)
      for f = 0L, n_files - 1L do begin
        times[f] = files[f].obsday_hours
        vcrosstalk[f] = files[f].vcrosstalk_metric
      endfor
      mg_log, 'plotting V cross talk for %s nm', wave_regions[w], $
              name=run.logger_name, /info
      ucomp_vcrosstalk_plots_wave_region, run.date, $
                                          wave_regions[w], $
                                          output_dir, $
                                          times, $
                                          vcrosstalk, $
                                          max_value=run->line(wave_regions[w], 'gbu_max_v_metric')
    endif
  endfor

  done:
end
