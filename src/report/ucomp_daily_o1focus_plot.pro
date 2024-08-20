; docformat = 'rst'

;+
; Daily plot of the O1FOCUSE values for the day.
;
; :Params:
;   obsday_index : in, required, type=integer
;     index used to identify observing day in database tables
;   db : in, required, type=object
;     database object
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_daily_o1focus_plot, wave_region, obsday_index, db, run=run
  compile_opt strictarr

  mg_log, 'plotting O1 focus position...', name=run.logger_name, /info

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
  device, set_resolution=[1280, 384], $
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

  time_range = [16.0, 28.0]
  !null = ucomp_hours_format(/minutes)

  o1focus_range = mg_range(data.o1focus)
  o1focus_range += ((o1focus_range[1] - o1focus_range[0]) > 0.1) * [-1.0, 1.0]
  o1focus_range[0] >= 0.0

  mg_range_plot, [hours], [data.o1focus], $
                 title=string(wave_region, pdate, format='%s nm O1 focus position for %s'), $
                 xtitle='Hours [UT]', ytitle='O1 focus position [mm]', $
                 xrange=time_range, xtickformat='ucomp_hours_format', $
                 /ynozero, ystyle=1, yrange=o1focus_range, yticks=5, $
                 background=background_color, color=color, charsize=charsize, $
                 clip_thick=2.0, clip_color=clip_color, psym=6, symsize=symsize

  ; save plots image file
  output_filename = filepath(string(run.date, wave_region, $
                                    format='(%"%s.ucomp.%s.daily.o1focus.gif")'), $
                             subdir=ucomp_decompose_date(run.date), $
                             root=run->config('engineering/basedir'))
  write_gif, output_filename, tvrd(), r, g, b

  done:
  if (n_elements(original_rgb) gt 0L) then tvlct, original_rgb
  if (n_elements(original_decomposed) gt 0L) then device, decomposed=original_decomposed
  if (n_elements(original_device) gt 0L) then set_plot, original_device
end


; main-level example program

date = '20240409'
config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

wave_region = '1074'

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)
obsday_index = ucomp_db_obsday_insert(run.date, db, $
                                      status=status, $
                                      logger_name=run.logger_name)

ucomp_daily_o1focus_plot, wave_region, obsday_index, db, run=run

obj_destroy, [db, run]

end
