; main-level example

date = '20220310'
wave_region = '1074'
mode = 'test'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, mode, config_filename)

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      status=status, $
                      log_statements=run->config('database/log_statements'))
help, status
sw_index = ucomp_db_sw_insert(db, $
                              status=status, $
                              logger_name=run.logger_name)
help, status
obsday_index = ucomp_db_obsday_insert(date, db, $
                                      status=status, $
                                      logger_name=run.logger_name)
help, status

ucomp_db_l2_average_insert, wave_region, obsday_index, sw_index, db, run=run

obj_destroy, run

end
