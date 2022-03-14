; docformat = 'rst'

;+
; Plot the centering information for all the images in the run.
;
; :Params:
;   filename : in, required, type=string
;     output filename
;
; :Keywords:
;   run : in, required, type=object
;     KCor run object
;-
pro ucomp_plot_centering_info, filename, run=run
  compile_opt strictarr

  mg_log, 'plotting centering info...', name=run.logger_name, /info

  files = run->get_files(data_type='sci', count=n_files)
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
  
  charsize = 0.30
  symsize  = 0.25

  x_range    = (1280.0 - 1.0) / 2.0 + [-40.0, 40.0]
  y_range    = (1024.0 - 1.0) / 2.0 + [-40.0, 40.0]
  r_range    = 335.0 + [-20.0, 20.0]
  time_range = [16.0, 28.0]

  n_cameras = 2L
  n_plots   = 3 * n_cameras   ; x, y, and radius
  !p.multi  = [0, 2, n_plots / n_cameras, 0, 1]

  hours  = fltarr(n_files) + !values.f_nan
  rcam_x = fltarr(n_files) + !values.f_nan
  rcam_y = fltarr(n_files) + !values.f_nan
  rcam_r = fltarr(n_files) + !values.f_nan
  tcam_x = fltarr(n_files) + !values.f_nan
  tcam_y = fltarr(n_files) + !values.f_nan
  tcam_r = fltarr(n_files) + !values.f_nan

  for f = 0L, n_files - 1L do begin
    hours[f] = files[f].obsday_hours + 10.0

    if (files[f].ok) then begin
      rcam_geometry = files[f].rcam_geometry
      if (~obj_valid(rcam_geometry) || rcam_geometry.occulter_error ne 0) then continue
      rcam_x[f] = rcam_geometry.occulter_center[0]
      rcam_y[f] = rcam_geometry.occulter_center[1]
      rcam_r[f] = rcam_geometry.occulter_radius

      tcam_geometry = files[f].tcam_geometry
      if (~obj_valid(tcam_geometry) || tcam_geometry.occulter_error ne 0) then continue
      tcam_x[f] = tcam_geometry.occulter_center[0]
      tcam_y[f] = tcam_geometry.occulter_center[1]
      tcam_r[f] = tcam_geometry.occulter_radius
    endif
  endfor

  !null = ucomp_hours_format(/minutes)

  if (total(finite(rcam_x)) gt 0L) then begin
    mg_range_plot, hours, rcam_x, $
                   title=string(pdate, format='RCAM x-coordinate of occulter center for %s'), $
                   xtitle='Hours [UT]', ytitle='x-coordinate [pixels]', $
                   xrange=time_range, xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=x_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
  endif
  if (total(finite(rcam_y)) gt 0L) then begin
    mg_range_plot, hours, rcam_y, $
                   title=string(pdate, format='RCAM y-coordinate of occulter center for %s'), $
                   xtitle='Hours [UT]', ytitle='y-coordinate [pixels]', $
                   xstyle=1, xrange=time_range, xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=y_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
  endif
  if (total(finite(rcam_r)) gt 0L) then begin
    mg_range_plot, hours, rcam_r, $
                   title=string(pdate, format='RCAM occulter of radius for %s'), $
                   xtitle='Hours [UT]', ytitle='radius [pixels]', $
                   xstyle=1, xrange=time_range, xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=r_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
  endif

  if (total(finite(tcam_x)) gt 0L) then begin
    mg_range_plot, hours, tcam_x, $
                   title=string(pdate, format='TCAM x-coordinate of occulter center for %s'), $
                   xtitle='Hours [UT]', ytitle='x-coordinate [pixels]', $
                   xstyle=1, xrange=time_range, xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=x_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
  endif
  if (total(finite(tcam_y)) gt 0L) then begin
    mg_range_plot, hours, tcam_y, $
                   title=string(pdate, format='TCAM y-coordinate of occulter center for %s'), $
                   xtitle='Hours [UT]', ytitle='y-coordinate [pixels]', $
                   xstyle=1, xrange=time_range, xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=y_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
  endif
  if (total(finite(tcam_r)) gt 0L) then begin
    mg_range_plot, hours, tcam_r, $
                   title=string(pdate, format='TCAM occulter of radius for %s'), $
                   xtitle='Hours [UT]', ytitle='radius [pixels]', $
                   xstyle=1, xrange=time_range, xtickformat='ucomp_hours_format', $
                   /ynozero, ystyle=1, yrange=r_range, $
                   background=255, color=0, charsize=n_plots * charsize, $
                   clip_thick=2.0, psym=6, symsize=symsize
  endif

  write_gif, filename, tvrd()

  done:
  !p.multi = 0
  if (n_elements(original_rgb) gt 0L) then tvlct, original_rgb
  if (n_elements(original_decomposed) gt 0L) then device, decomposed=original_decomposed
  if (n_elements(original_device) gt 0L) then set_plot, original_device
end