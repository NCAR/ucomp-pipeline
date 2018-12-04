; docformat = 'rst'

pro ucomp_update_database, wave_type, run=run
  compile_opt strictarr

  mg_log, 'updating database for %s nm...', wave_type, $
          name=run.logger_name, /info

  ; get the files for the given wave_type
  run->getProperty, files=files, wave_type=wave_type, count=n_files
  if (n_files eq 0L) then begin
    mg_log, 'no files to insert', name=run.logger_name, /info
    return
  endif

  db = ucomp_db_connect(run->config('database/config_filename'), $
                        run->config('database/config_section'), $
                        status=status, $
                        logger_name=run.logger_name)
  if (status ne 0) then goto, cleanup

  obsday_index = ucomp_obsday_insert(run.date, db, $
                                     status=status, $
                                     logger_name=run.logger_name)
  if (status ne 0L) then goto, cleanup

  ucomp_db_raw_insert, files, obsday_index, db, logger_name=run.logger_name

  cleanup:
  if (obj_valid(db)) then obj_destroy, db
end
