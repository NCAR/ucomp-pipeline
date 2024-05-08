; docformat = 'rst'

;+
; Plot the centering information for all the images in the run.
;
; :Params:
;   filename : in, required, type=string
;     output filename
;   wave_region : in, required, type=string
;     wave region to plot
;
; :Keywords:
;   run : in, required, type=object
;     KCor run object
;-
pro ucomp_plot_temp_vs_voltage, filename, wave_region, run=run
  compile_opt strictarr

  mg_log, 'plotting temperature vs. voltage info...', name=run.logger_name, /info

  files = run->get_files(data_type='sci', wave_region=wave_region, count=n_files)
  if (n_files eq 0L) then goto, done

  pdate = string(ucomp_decompose_date(run.date), format='(%"%s-%s-%s")')

  ; set up graphics window & color table
  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, set_resolution=[768, 768], $
          decomposed=0, $
          set_colors=256, $
          z_buffering=0

  charsize = 1.1
  symsize  = 0.25

  temperature_range = [33.0, 36.0]
  voltage_range     = [0.0, 10.0]

  t_lcvr3 = fltarr(n_files)
  v_lcvr3 = fltarr(n_files)

  center_wavelength = run->line(wave_region, 'center_wavelength')
  for f = 0L, n_files - 1L do begin
    t_lcvr3[f] = files[f].t_lcvr3

    center_indices = where((files[f].wavelengths - center_wavelength) lt 0.001, n_center_indices)
    if (n_center_indices eq 0L) then begin
      v_lcvr3[f] = !values.f_nan
    endif else begin
      v_lcvr3[f] = mean((files[f].v_lcvr3)[center_indices], /nan)
    endelse
  endfor

  if (total(finite(t_lcvr3), /integer) gt 0L $
        || total(finite(v_lcvr3), /integer) gt 0L) then begin
    mg_range_plot, t_lcvr3, v_lcvr3, $
                   title=string(center_wavelength, pdate, $
                                format='%0.3f nm temperature vs. voltage for LCVR3 for %s'), $
                   xtitle='LCVR3 temperature [C]', ytitle='LCVR3 voltage [V]', $
                   xstyle=1, xrange=temperature_range, $
                   /ynozero, ystyle=1, yrange=voltage_range, $
                   background=255, color=0, charsize=charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize

    write_gif, filename, tvrd()
  endif else begin
    mg_log, 'no finite temperature or voltage values, skipping', $
            name=run.logger_name, /info
  endelse

  done:
  !p.multi = 0
  if (n_elements(original_rgb) gt 0L) then tvlct, original_rgb
  if (n_elements(original_decomposed) gt 0L) then device, decomposed=original_decomposed
  if (n_elements(original_device) gt 0L) then set_plot, original_device
end
