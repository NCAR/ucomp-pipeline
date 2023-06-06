; docformat = 'rst'

pro ucomp_plot_mission_quality, db, wave_region, start_date, end_date
  compile_opt strictarr

  start_components = long(ucomp_decompose_date(start_date))
  start_jd = julday(start_components[1], start_components[2], start_components[0], $
                    0.0, 0.0, 0.0)
  end_components = long(ucomp_decompose_date(end_date))
  end_jd = julday(end_components[1], end_components[2], end_components[0], $
                  0.0, 0.0, 0.0)

  n_days = long(end_jd - start_jd)

  n_quality_files = lonarr(2, n_days)
  jds = dblarr(n_days)


  d = 0L
  date = start_date
  while (date ne end_date) do begin
    date_components = ucomp_decompose_date(date)
    jds[d] = julday(long(date_components[1]), $
                    long(date_components[2]), $
                    long(date_components[0]), $
                    0.0, 0.0, 0.0)

    date_string = strjoin(date_components, '-')
    query = 'select day_id from mlso_numfiles where obs_day = ''%s'''
    obsday_ids = db->query(query, date_string, $
                           count=n_dates, error=error, sql_statement=sql)

    if (n_dates gt 0L) then begin
      query = 'select * from ucomp_raw where wave_region=''%s'' and obsday_id=%d order by date_obs'
      data = db->query(query, wave_region, obsday_ids[0], $
                       count=n_files, error=error, sql_statement=sql)

      if (n_files gt 0L) then begin
        !null = where(data.quality_id eq 1, n_day_good_files)
        !null = where(data.quality_id ne 1, n_day_bad_files)
        n_quality_files[0, d] = n_day_good_files
        n_quality_files[1, d] = n_day_bad_files
      endif
    endif

    print, date, total(n_quality_files[*, d], /preserve_type), wave_region, $
           format='%s: %d %s nm files'

    d += 1L
    date = ucomp_increment_date(date)
  endwhile

print, jds[0]
stop
  colors = ['008800'x, '000088'x]
  !null = label_date(date_format='%Y-%N-%D')
  window, xsize=1000, ysize=300, /free
  mg_stacked_histplot, jds, $
                       n_quality_files, $
                       axis_color='000000'x, $
                       background='ffffff'x, color=colors, /fill, $
                       charsize=0.85, $
                       xtitle='Date', ytitle='# of files', $
                       xstyle=9, xyrange=[start_jd, end_jd], xtickformat='label_date', $
                       ystyle=9, yrange=[0, 500]
end


; main-level example

start_date = '20210526'
end_date = '20221201'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(start_date, 'analysis', config_filename)

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

wave_region = '1074'

ucomp_plot_mission_quality, db, wave_region, start_date, end_date

obj_destroy, [db, run]

end
