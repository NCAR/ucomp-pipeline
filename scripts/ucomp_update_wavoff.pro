; docformat = 'rst'

;+
; Update ucomp_raw.wave_offset from all the raw files.
;-
pro ucomp_update_wavoff, date, config_filename
  compile_opt strictarr

  run = ucomp_run(date, 'wavoff', config_filename)

  mg_log, 'updating ucomp_raw.wave_offset for %d', date, name=run.logger_name, /info

  db = ucomp_db_connect(run->config('database/config_filename'), $
                        run->config('database/config_section'), $
                        logger_name=run.logger_name, $
                        log_statements=run->config('database/log_statements'), $
                        status=status)

  l0_dir = filepath(date, root=run->config('raw/basedir'))
  raw_files = file_search(filepath('*.fts', root=l0_dir), count=n_raw_files)

  for f = 0L, n_raw_files - 1L do begin
    basename = file_basename(raw_files[f])
    mg_log, '%d/%d: %s...', f + 1, n_raw_files, basename, $
            name=run.logger_name, /info

    ucomp_read_raw_data, raw_files[f], $
                         primary_header=primary_header, $
                         repair_routine=run->epoch('raw_data_repair_routine'), $
                         metadata_fixes=run.metadata_fixes, $
                         all_zero=all_zero, $
                         use_occulter_id=run->epoch('use_occulter_id'), $
                         occulter_id=run->epoch('occulter_id'), $
                         logger=run.logger_name

    wave_offset = ucomp_getpar(primary_header, 'WAVOFF')
    mg_log, 'wave_offset=%f', wave_offset, /debug, name=run.logger_name
    sql_cmd = 'update ucomp_raw set wave_offset=%0.3f where file_name=\"%s\";'
    db->execute, sql_cmd, wave_offset, basename, $
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

  obj_destroy, [db, run]
end


; main-level example

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'ucomp-config'], $
                           root=mg_src_root())
ucomp_update_wavoff, '20210715', config_filename

end
