; docformat = 'rst'

;+
; Plot eccentricity of occulter fit.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region, e.g., "1074"
;   obsday_index : in, required, type=integer
;     index used to identify observing day in database tables
;   db : in, required, type=object
;     `UCoMPdbMySQL` object
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_plot_eccentricity, wave_region, obsday_index, db, run=run
  compile_opt strictarr

  mg_log, 'plotting eccentricity info...', name=run.logger_name, /info

  query = 'select * from ucomp_eng where wave_region=''%s'' and obsday_id=%d order by date_obs'
  data = db->query(query, wave_region, obsday_index, $
                   count=n_files, error=error, fields=fields, sql_statement=sql)
  if (n_files eq 0L) then begin
    mg_log, 'no files found', name=run.logger_name, /warn
    goto, done
  endif else begin
    mg_log, '%d files found', n_files, name=run.logger_name, /info
  endelse

  hours = fltarr(n_files) + !values.f_nan
  for f = 0L, n_files - 1L do hours[f] = ucomp_dateobs2hours((data.date_obs)[f]) + 10.0

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

  tvlct, 0, 0, 0, 0
  tvlct, 255, 255, 255, 1
  tvlct, 255, 0, 0, 2
  tvlct, r, g, b, /get

  color            = 0
  background_color = 1
  clip_color       = 2

  charsize         = 0.9
  psym             = 6
  symsize          = 0.25

  !p.multi = [0, 2, 2]

  time_range = [16.0, 28.0]
  !null = ucomp_hours_format(/minutes)

  eccentricity_range = [0.0, 0.25]
  angle_range = [0.0, 180.0]

  mg_range_plot, [hours], [data.rcam_eccentricity], $
                 title=string(wave_region, pdate, format='%s nm RCAM eccentricity of occulter center for %s'), $
                 xtitle='Hours [UT]', ytitle='Eccentricity', $
                 xrange=time_range, xtickformat='ucomp_hours_format', $
                 /ynozero, ystyle=1, yrange=eccentricity_range, yticks=5, $
                 background=background_color, color=color, charsize=charsize, $
                 clip_thick=2.0, clip_color=clip_color, psym=6, symsize=symsize
  mg_range_plot, [hours], [data.tcam_eccentricity], $
                 title=string(wave_region, pdate, format='%s nm TCAM eccentricity of occulter center for %s'), $
                 xtitle='Hours [UT]', ytitle='Eccentricity', $
                 xrange=time_range, xtickformat='ucomp_hours_format', $
                 /ynozero, ystyle=1, yrange=eccentricity_range, yticks=5, $
                 background=background_color, color=color, charsize=charsize, $
                 clip_thick=2.0, clip_color=clip_color, psym=6, symsize=symsize

  mg_range_plot, [hours], [data.rcam_ellipse_angle], $
                 title=string(wave_region, pdate, format='%s nm RCAM ellipse angle of occulter center for %s'), $
                 xtitle='Hours [UT]', ytitle='Ellipse angle [degrees]', $
                 xrange=time_range, xtickformat='ucomp_hours_format', $
                 /ynozero, ystyle=1, yrange=angle_range, yticks=6, $
                 background=background_color, color=color, charsize=charsize, $
                 clip_thick=2.0, clip_color=clip_color, psym=6, symsize=symsize
  mg_range_plot, [hours], [data.tcam_ellipse_angle], $
                 title=string(wave_region, pdate, format='%s nm TCAM ellipse angle of occulter center for %s'), $
                 xtitle='Hours [UT]', ytitle='Ellipse angle [degrees]', $
                 xrange=time_range, xtickformat='ucomp_hours_format', $
                 /ynozero, ystyle=1, yrange=angle_range, yticks=6, $
                 background=background_color, color=color, charsize=charsize, $
                 clip_thick=2.0, clip_color=clip_color, psym=6, symsize=symsize

  ; save plots image file
  output_filename = filepath(string(run.date, wave_region, $
                                    format='(%"%s.ucomp.%s.daily.eccentricity.gif")'), $
                             subdir=ucomp_decompose_date(run.date), $
                             root=run->config('engineering/basedir'))
  write_gif, output_filename, tvrd(), r, g, b

  done:
  !p.multi = 0
  if (n_elements(original_rgb) gt 0L) then tvlct, original_rgb
  if (n_elements(original_decomposed) gt 0L) then device, decomposed=original_decomposed
  if (n_elements(original_device) gt 0L) then set_plot, original_device
end
