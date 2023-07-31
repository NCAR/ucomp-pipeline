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

  n_quality_files = lonarr(3, n_days)   ; good, bad GBU, and bad quality
  jds = dblarr(n_days)

  producttype_results = db->query('select * from mlso_producttype where producttype="IQUV" and description like "UCoMP%%";')
  level1_producttype_id = producttype_results.producttype_id

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
    day_id = obsday_ids[0].day_id

    if (n_dates gt 0L) then begin
      query = 'select * from ucomp_raw where wave_region=''%s'' and obsday_id=%d order by date_obs'
      data = db->query(query, wave_region, day_id, $
                       count=n_total_files, status=status, error=error, sql_statement=sql)

      query = 'select ucomp_raw.file_name, ucomp_raw.quality_bitmask, ucomp_file.gbu, ucomp_raw.obsday_id, ucomp_raw.wave_region from ucomp_raw inner join ucomp_file on ucomp_raw.file_name = ucomp_file.l0_file_name where ucomp_raw.wave_region=''%s'' and ucomp_file.producttype_id=%d and ucomp_raw.obsday_id=%d;'
      data = db->query(query, wave_region, level1_producttype_id, day_id, $
                       count=n_ok_files, status=status, error=error, sql_statement=sql)
      if (n_ok_files gt 0L) then begin
        !null = where(data.gbu eq 0, n_good_files)
        n_quality_files[0, d] = n_good_files
        n_quality_files[1, d] = n_ok_files - n_good_files
        n_quality_files[2, d] = n_total_files - n_ok_files
      endif
    endif

    print, date, total(n_quality_files[*, d], /preserve_type), wave_region, n_quality_files[0, d], $
           format='%s: %d %s nm files (%d good ones)'

    d += 1L
    date = ucomp_increment_date(date)
  endwhile

  charsize = 1.0
  colors = ['008800'x, '30a0c0'x, '3366ff'x]
  !null = label_date(date_format='%Y-%N-%D')
  window, xsize=1500, ysize=400, /free
  mg_stacked_histplot, jds, $
                       n_quality_files, $
                       title=string(wave_region, format='Quality files for %s nm'), $
                       axis_color='000000'x, $
                       background='ffffff'x, color=colors, /fill, $
                       charsize=charsize, $
                       xtitle='Date', ytitle='# of files', $
                       xstyle=9, xrange=[start_jd, end_jd], xtickformat='label_date', $
                       ystyle=9, yrange=[0, 500]
  mg_legend, item_name=['good', 'bad GBU', 'bad quality'], $
             item_color=colors, $
             item_psym=mg_usersym(/square, /fill), $
             item_symsize=1.5, $
             color='000000'x, $
             charsize=1.0, $
             gap=0.075, $
             line_bump=0.0, $
             position=[0.85, 0.8, 0.9575, 0.90]
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

wave_regions = ['530', '637', '656', '670', '691', '706', '761', '789', '802', $
                '991', '1074', '1079', '1083']
;wave_regions = ['1074']
for w = 0L, n_elements(wave_regions) - 1L do begin
  ucomp_plot_mission_quality, db, wave_regions[w], start_date, end_date
endfor

obj_destroy, [db, run]

end
