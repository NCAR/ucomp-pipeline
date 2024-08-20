; docformat = 'rst'

pro ucomp_rolling_o1focus_plot, wave_region, db, $
                                n_days=n_days, mission=mission, $
                                run=run
  compile_opt strictarr

  ; number of days to include in the plot
  _n_days = mg_default(n_days, 28L)

  mg_log, 'producing %d day %s nm O1 focus plot', _n_days, wave_region, $
          name=run.logger_name, /info

  ; query database for data
  end_date_tokens = long(ucomp_decompose_date(run.date))
  end_date = string(end_date_tokens, format='(%"%04d-%02d-%02d")')
  end_datetime = string(end_date_tokens, format='(%"%04d-%02d-%02dT23:59:59")')
  end_date_jd = julday(end_date_tokens[1], $
                       end_date_tokens[2], $
                       end_date_tokens[0], $
                       23, 59, 59)
  start_date_jd = end_date_jd - _n_days + 1
  start_date = string(start_date_jd, $
                      format='(C(CYI4.4, "-", CMoI2.2, "-", CDI2.2))')
  start_datetime = string(start_date_jd, $
                          format='(C(CYI4.4, "-", CMoI2.2, "-", CDI2.2, "T23:59:59"))')

  if (keyword_set(mission)) then begin
    query = 'select * from ucomp_eng where wave_region=''%s'' order by date_obs'
    data = db->query(query, wave_region, $
                     count=n_rows, error=error, fields=fields, sql_statement=sql)
  endif else begin
    query = 'select * from ucomp_eng where wave_region=''%s'' and date_obs between ''%s'' and ''%s'' order by date_obs'
    data = db->query(query, wave_region, start_datetime, end_datetime, $
                     count=n_rows, error=error, fields=fields, sql_statement=sql)
  endelse

  if (n_rows gt 0L) then begin
    mg_log, '%d files between %s and %s', n_rows, start_date, end_date, $
            name=run.logger_name, /debug
  endif else begin
    mg_log, 'no data found between %s and %s', start_date, end_date, $
            name=run.logger_name, /warn
    goto, done
  endelse

  jds = ucomp_dateobs2julday(data.date_obs)
  !null = label_date(date_format='%Y-%N-%D')

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

  date_range = [start_date_jd, end_date_jd]

  o1focus_range = mg_range(data.o1focus)
  o1focus_range += ((o1focus_range[1] - o1focus_range[0]) > 0.1) * [-1.0, 1.0]
  o1focus_range[0] >= 0.0

  month_ticks = mg_tick_locator([jds[0], jds[-1]], /months)
  if (n_elements(month_ticks) eq 0L) then begin
    month_ticks = 1L
  endif else begin
    month_ticks = month_ticks[0:*:3]
  endelse

  mg_range_plot, [jds], [data.o1focus], $
                 title=string(wave_region, $
                              keyword_set(mission) ? 'over the UCoMP mission' : string(start_date, end_date, format='for %s to %s'), $
                              format='%s nm O1 focus position %s'), $
                 xtitle='Hours [UT]', ytitle='O1 focus position [mm]', $
                 xrange=date_range, $
                 xtickformat='label_date', $
                 xtickv=month_ticks, $
                 xticks=n_elements(month_ticks) - 1L, $
                 /ynozero, ystyle=1, yrange=o1focus_range, yticks=5, $
                 background=background_color, color=color, charsize=charsize, $
                 clip_thick=2.0, clip_color=clip_color, psym=6, symsize=symsize

  ; save plots image file
  output_filename = filepath(string(run.date, wave_region, $
                                    keyword_set(mission) ? 'mission' : string(_n_days, format='%dday'), $
                                    format='(%"%s.ucomp.%s.%s.o1focus.gif")'), $
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

ucomp_rolling_o1focus_plot, wave_region, db, n_days=60, run=run
ucomp_rolling_o1focus_plot, wave_region, db, /mission, run=run

obj_destroy, [db, run]

end
