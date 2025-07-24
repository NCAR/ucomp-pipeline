; docformat = 'rst'

pro ucomp_update_db_filesize, date, config_filename
  compile_opt strictarr

  run = ucomp_run(date, 'script', config_filename)
  db = ucomp_db_connect(run->config('database/config_filename'), $
                        run->config('database/config_section'), $
                        logger_name=run.logger_name, $
                        log_statements=run->config('database/log_statements'), $
                        status=status)

  obsday_id = ucomp_db_obsday_insert(date, db, status=status, logger_name=run.logger_name)

  ; find files on the given day
  query = 'select * from ucomp_file where obsday_id=%d order by date_obs'
  data = db->query(query, obsday_id, $
                   count=n_files, error=error, fields=fields, sql_statement=sql)

  web_basedir = run->config('results/web_basedir')
  web_dir = filepath('', subdir=ucomp_decompose_date(date), root=web_basedir)

  ; for each file, update filesize
  for f = 0L, n_files - 1L do begin
    filename = filepath(data[f].file_name, root=web_dir)
    if (file_test(filename, /regular)) then begin
      filesize = mg_filesize(filename)
      mg_log, '[%08d] %s: updating to %d bytes', $
              data[f].file_id, data[f].file_name, filesize, $
              /info, name=run.logger_name
      sql_cmd = 'update ucomp_file set filesize=%d where file_id=%d'
      db->execute, sql_cmd, filesize, data[f].file_id
    endif else begin
      mg_log, '[%08d] %s: file does not exist', $
              data[f].file_id, data[f].file_name, $
              /info, name=run.logger_name
    endelse
  endfor

  obj_destroy, [db, run]
end


; main-level example program

date = '20240330'
config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, subdir=['..', '..', 'ucomp-config'], root=mg_src_root())
ucomp_update_db_filesize, date, config_filename

end
