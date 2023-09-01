; docformat = 'rst'

;+
; Plot the centering information for all the images in the run.
;
; :Params:
;   filename : in, required, type=string
;     output filename
;   radiusdiff_filename : in, required, type=string
;     output filename for radius difference plot
;   wave_region : in, required, type=string
;     wave region to plot
;
; :Keywords:
;   run : in, required, type=object
;     KCor run object
;-
pro ucomp_plot_centering_info, filename, radiusdiff_filename, wave_region, run=run
  compile_opt strictarr

  mg_log, 'plotting centering info...', name=run.logger_name, /info

  files = run->get_files(data_type='sci', wave_region=wave_region, count=n_files)
  if (n_files eq 0L) then goto, done

  pdate = string(ucomp_decompose_date(run.date), format='(%"%s-%s-%s")')

  ; set up graphics window & color table
  original_device = !d.name
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, set_resolution=[1280, 768], $
          decomposed=0, $
          set_colors=256, $
          z_buffering=0

  charsize = 0.4
  symsize  = 0.25

  x_range    = (1280.0 - 1.0) / 2.0 + [-40.0, 40.0]
  y_range    = (1024.0 - 1.0) / 2.0 + [-40.0, 40.0]
  r_range    = 335.0 + [-20.0, 20.0]

  !null = ucomp_hours_format(/minutes)
  time_range = [16.0, 28.0]
  time_ticks = time_range[1] - time_range[0]

  chisq_max = run->line(wave_region, 'gbu_max_fit_chisq')
  chisq_range = [0.0, 2.0 * chisq_max]

  n_cameras = 2L
  n_plots   = 4L   ; x, y, radius, chi-squared
  !p.multi  = [0, n_cameras, n_plots, 0, 1]

  hours      = fltarr(n_files) + !values.f_nan
  rcam_x     = fltarr(n_files) + !values.f_nan
  rcam_y     = fltarr(n_files) + !values.f_nan
  rcam_r     = fltarr(n_files) + !values.f_nan
  rcam_chisq = fltarr(n_files) + !values.f_nan
  tcam_x     = fltarr(n_files) + !values.f_nan
  tcam_y     = fltarr(n_files) + !values.f_nan
  tcam_r     = fltarr(n_files) + !values.f_nan
  tcam_chisq = fltarr(n_files) + !values.f_nan

  for f = 0L, n_files - 1L do begin
    hours[f] = files[f].obsday_hours + 10.0

    if (files[f].ok) then begin
      rcam_geometry = files[f].rcam_geometry
      if (~obj_valid(rcam_geometry) || rcam_geometry.occulter_error ne 0) then continue
      rcam_x[f]     = rcam_geometry.occulter_center[0]
      rcam_y[f]     = rcam_geometry.occulter_center[1]
      rcam_r[f]     = rcam_geometry.occulter_radius
      rcam_chisq[f] = rcam_geometry.occulter_chisq

      tcam_geometry = files[f].tcam_geometry
      if (~obj_valid(tcam_geometry) || tcam_geometry.occulter_error ne 0) then continue
      tcam_x[f]     = tcam_geometry.occulter_center[0]
      tcam_y[f]     = tcam_geometry.occulter_center[1]
      tcam_r[f]     = tcam_geometry.occulter_radius
      tcam_chisq[f] = tcam_geometry.occulter_chisq
    endif
  endfor

  if (total(finite(rcam_x)) gt 0L) then begin
    mg_range_plot, hours, rcam_x, $
                   title=string(wave_region, pdate, format='%s nm RCAM x-coordinate of occulter center for %s'), $
                   xtitle='Hours [UT]', ytitle='x-coordinate [pixels]', $
                   xstyle=1, xrange=time_range, xticks=time_ticks, $
                   xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=x_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
  endif
  if (total(finite(rcam_y)) gt 0L) then begin
    mg_range_plot, hours, rcam_y, $
                   title=string(wave_region, pdate, format='%s nm RCAM y-coordinate of occulter center for %s'), $
                   xtitle='Hours [UT]', ytitle='y-coordinate [pixels]', $
                   xstyle=1, xrange=time_range, xticks=time_ticks, $
                   xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=y_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
  endif
  if (total(finite(rcam_r)) gt 0L) then begin
    mg_range_plot, hours, rcam_r, $
                   title=string(wave_region, pdate, format='%s nm RCAM occulter of radius for %s'), $
                   xtitle='Hours [UT]', ytitle='Radius [pixels]', $
                   xstyle=1, xrange=time_range, xticks=time_ticks, $
                   xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=r_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
  endif
  if (total(finite(rcam_r)) gt 0L) then begin
    mg_range_plot, hours, rcam_chisq, $
                   title=string(wave_region, pdate, format='%s nm RCAM occulter fit chi-squared for %s'), $
                   xtitle='Hours [UT]', ytitle='Chi-squared', $
                   xstyle=1, xrange=time_range, xticks=time_ticks, $
                   xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=chisq_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
    plots, time_range, fltarr(2) + chisq_max, linestyle=1, color=0
  endif

  if (total(finite(tcam_x)) gt 0L) then begin
    mg_range_plot, hours, tcam_x, $
                   title=string(wave_region, pdate, format='%s nm TCAM x-coordinate of occulter center for %s'), $
                   xtitle='Hours [UT]', ytitle='x-coordinate [pixels]', $
                   xstyle=1, xrange=time_range, xticks=time_ticks, $
                   xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=x_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
  endif
  if (total(finite(tcam_y)) gt 0L) then begin
    mg_range_plot, hours, tcam_y, $
                   title=string(wave_region, pdate, format='%s nm TCAM y-coordinate of occulter center for %s'), $
                   xtitle='Hours [UT]', ytitle='y-coordinate [pixels]', $
                   xstyle=1, xrange=time_range, xticks=time_ticks, $
                   xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=y_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
  endif
  if (total(finite(tcam_r)) gt 0L) then begin
    mg_range_plot, hours, tcam_r, $
                   title=string(wave_region, pdate, format='%s nm TCAM occulter of radius for %s'), $
                   xtitle='Hours [UT]', ytitle='Radius [pixels]', $
                   xstyle=1, xrange=time_range, xticks=time_ticks, $
                   xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=r_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
  endif
  if (total(finite(rcam_r)) gt 0L) then begin
    mg_range_plot, hours, tcam_chisq, $
                   title=string(wave_region, pdate, format='%s nm TCAM occulter fit chi-squared for %s'), $
                   xtitle='Hours [UT]', ytitle='Chi-squared', $
                   xstyle=1, xrange=time_range, xticks=time_ticks, $
                   xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=chisq_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
    plots, time_range, fltarr(2) + chisq_max, linestyle=1, color=0
  endif

  write_gif, filename, tvrd()

  !p.multi = 0

  if ((total(finite(tcam_r)) gt 0L) && (total(finite(tcam_r)) gt 0L)) then begin
    device, set_resolution=[1280, 768]
    mg_range_plot, hours, rcam_r - tcam_r, $
                   title=string(wave_region, pdate, $
                                format='%s nm RCAM - TCAM occulter radius for %s'), $
                   xtitle='Hours [UT]', ytitle='RCAM - TCAM radius [pixels]', $
                   xstyle=1, xrange=time_range, xticks=time_ticks, $
                   xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=[-2.0, 2.0], $
                   background=255, color=0, charsize=1.0, $
                   clip_thick=2.0, psym=6, symsize=symsize
    plots, [hours[0], hours[-1]], fltarr(2), linestyle=3, color=0
    write_gif, radiusdiff_filename, tvrd()
  endif

  done:
  !p.multi = 0
  if (n_elements(original_rgb) gt 0L) then tvlct, original_rgb
  if (n_elements(original_decomposed) gt 0L) then device, decomposed=original_decomposed
  if (n_elements(original_device) gt 0L) then set_plot, original_device
end
