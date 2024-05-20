; main-level example program

date = '20210922'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

wave_regions = run->all_lines()
for w = 0L, n_elements(wave_regions) - 1L do begin
  ucomp_rolling_flat_plots, wave_regions[w], db, run=run
endfor

obj_destroy, [db, run]

end
