; docformar = 'rst'

;+
; Clear entries for the given date in the database.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_db_clearday, run=run
  compile_opt strictarr

  ; clear database for the day
  if (run->config('database/update')) then begin
    mg_log, 'clearing database for the day', name=run.logger_name, /info
  endif else begin
    mg_log, 'skipping clearing database', name=run.logger_name, /info
    goto, done
  endelse

  filename = run->config('database/config_filename')
  section = run->config('database/config_section')

  if (filename eq '' || section eq '') then begin
    mg_log, 'config filename or section not specified', name=run.logger_name, /error
    mg_log, 'cannot connect to database', name=run.logger_name, /error
    goto, done
  endif

  db = ucomp_db_connect(filename, section, $
                        status=status, $
                        logger_name=run.logger_name, $
                        log_statements=run->config('database/log_statements'))
  if (status ne 0) then goto, done

  obsday_index = ucomp_db_obsday_insert(run.date, db, $
                                        status=status, $
                                        logger_name=run.logger_name)
  if (status ne 0L) then goto, done

  tables = 'ucomp_' + ['raw', 'file', 'eng', 'cal', $
             'sci_dynamics', 'sci_polarization']
  for t = 0L, n_elements(tables) - 1L do begin
    ucomp_db_cleartable, obsday_index, tables[t], db, $
                         logger_name=run.logger_name
  endfor

  ; clear num_ucomp field of mlso_numfiles
  sql_cmd = 'update mlso_numfiles set num_ucomp=0 where day_id=%d'
  db->execute, sql_cmd, obsday_index

  done:
  if (arg_present(db)) then obj_destroy, db
  mg_log, 'done', name=run.logger_name, /info
end
