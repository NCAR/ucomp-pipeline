; docformat = 'rst'

pro ucomp_plot_fit_chisq, db, wave_region, start_date, end_date
  compile_opt strictarr

  start_components = long(ucomp_decompose_date(start_date))
  start_jd = julday(start_components[1], start_components[2], start_components[0], $
                    0.0, 0.0, 0.0)
  end_components = long(ucomp_decompose_date(end_date))
  end_jd = julday(end_components[1], end_components[2], end_components[0], $
                  0.0, 0.0, 0.0)

  query = 'select * from ucomp_eng where wave_region=''%s'' order by date_obs'
  data = db->query(query, wave_region, $
                   count=n_files, error=error, sql_statement=sql)

  jds = dblarr(n_files)
  for f = 0L, n_files - 1L do jds[f] = ucomp_dateobs2julday(data[f].date_obs)

  charsize = 1.0
  !null = label_date(date_format='%Y-%N-%D')
  window, xsize=1500, ysize=400, /free
  !p.multi = [0, 1, 2]

  gbu_max_fit_chisq = 0.1

  mg_range_plot, jds, data.rcam_occulter_chisq, $
                 title=string(wave_region, format='%s nm RCAM occuler chi squared'), $
                 xstyle=9, xrange=[start_jd, end_jd], xtickformat='label_date', $
                 ystyle=9, yrange=[0.0, gbu_max_fit_chisq], $
                 color='000000'x, background='ffffff'x, $
                 clip_thick=2.0, clip_color='0000ff'x, psym=6, symsize=0.2

  mg_range_plot, jds, data.tcam_occulter_chisq, $
                 title=string(wave_region, format='%s nm TCAM occuler chi squared'), $
                 xstyle=9, xrange=[start_jd, end_jd], xtickformat='label_date', $
                 ystyle=9, yrange=[0.0, gbu_max_fit_chisq], $
                 color='000000'x, background='ffffff'x, $
                 clip_thick=2.0, clip_color='0000ff'x, psym=6, symsize=0.2

  !p.multi = 0
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

for w = 0L, n_elements(wave_regions) - 1L do begin
  ucomp_plot_fit_chisq, db, wave_regions[w], start_date, end_date
endfor

obj_destroy, [db, run]

end
