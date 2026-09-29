; docformat = 'rst'

pro ucomp_update_process, db
  compile_opt strictarr

  q = 'select obsday_id, file_name, ucomp_sw_id from ucomp_file group by obsday_id order by date_obs;'
  results = db->query(q, count=n_days)
  for d = 0L, n_days - 1L do begin
    s = 'insert into ucomp_process (obsday_id, ucomp_sw_id, date_processed, status) values (%d, %d, NULL, ''processed'')'
    db->execute, s, results[d].obsday_id, results[d].ucomp_sw_id
  endfor
end


; main-level example program

start_date = '20210715'
config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(start_date, 'update_process', config_filename)

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

ucomp_update_process, db

obj_destroy, [db, run]

end

