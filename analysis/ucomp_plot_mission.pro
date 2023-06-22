; docformat = 'rst'

pro ucomp_plot_mission, db, wave_region, start_date, end_date
  compile_opt strictarr

  ucomp_plot_mission_quality, db, wave_region, start_date, end_date
  ucomp_plot_fit_chisq, db, wave_region, start_date, end_date
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

;wave_regions = ['530', '637', '656', '670', '691', '706', '761', '789', '802', $
;                '991', '1074', '1079', '1083']
wave_regions = ['1074']

for w = 0L, n_elements(wave_regions) - 1L do begin
  ucomp_plot_mission, db, wave_regions[w], start_date, end_date
endfor

obj_destroy, [db, run]

end
