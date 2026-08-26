; docformat = 'rst'

;+
; Update ucomp_file.rest_wavelength from all the level 2 files.
;-
pro ucomp_update_rest_wavelength, date, config_filename
  compile_opt strictarr

  run = ucomp_run(date, 'rest_wavelength', config_filename)

  mg_log, 'updating ucomp_file.rest_wavelength for %d', date, name=run.logger_name, /info

  db = ucomp_db_connect(run->config('database/config_filename'), $
                        run->config('database/config_section'), $
                        logger_name=run.logger_name, $
                        log_statements=run->config('database/log_statements'), $
                        status=status)

  sql_query = 'select file_name, rest_wavelength, mlso_numfiles.obs_day from ucomp_file inner join mlso_numfiles on obsday_id=mlso_numfiles.day_id where rest_wavelength is NULL and mlso_numfiles.obs_day=\"%s\" and producttype_id in (36, 37);'
  results = db->query(sql_query, $
                      strjoin(ucomp_decompose_date(date), '-'), $
                      count=n_rows, $
                      sql_statement=sql_statement, $
                      error_message=err_msg)

  mg_log, 'found %d level 2 files', n_rows, /info, name=run.logger_name

  process_basedir = run->config('processing/basedir')
  l2_dir = filepath('', subdir=[date, 'level2'], root=process_basedir)
  for f = 0L, n_rows - 1L do begin
    l2_filename = filepath(results[f].file_name, root=l2_dir)
    if (~file_test(l2_filename, /regular)) then begin
      mg_log, 'can''t find %s', results[f].file_name, /error, name=run.logger_name
      continue
    endif
    fits_open, l2_filename, fcb
    fits_read, fcb, !null, header, exten=4
    fits_close, fcb
    rest_wavelength = ucomp_getpar(header, 'RSTWVL')
    mg_log, '%s: %0.3f', results[f].file_name, rest_wavelength, /info, name=run.logger_name

    sql_cmd = 'update ucomp_file set rest_wavelength=%0.3f where file_name=\"%s\";'
    db->execute, sql_cmd, rest_wavelength, results[f].file_name, $
                 sql_statement=sql_statement, status=status, $
                 error_message=error_message, $
                 n_affected_rows=n_affected_rows, $
                 n_warnings=n_warnings
    mg_log, sql_statement, /debug, name=run.logger_name
    mg_log, '%d rows affected', n_affected_rows, /debug, name=run.logger_name
    mg_log, '%d warnings', n_warnings, /debug, name=run.logger_name
    if (status ne 0) then begin
      mg_log, 'SQL statement failed', /error, name=run.logger_name
      mg_log, error_message, /error, name=run.logger_name
    endif
  endfor
end


; main-level example

; config_basename = 'ucomp.reprocess.cfg'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'ucomp-config'], $
                           root=mg_src_root())
ucomp_update_rest_wavelength, '20221123', config_filename

end
