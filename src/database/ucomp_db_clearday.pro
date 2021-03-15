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
  if (~run->config('database/update')) then begin
    mg_log, 'skipping clearing database', name=run.logger_name, /info
    goto, done
  endif

  mg_log, 'clearing database for the day', name=run.logger_name, /info

  filename = run->config('database/config_filename')
  section = run->config('database/config_section')

  if (filename eq '' || section eq '') then begin
    mg_log, 'config filename or section not specified', $
            name=run.logger_name, /error
    mg_log, 'cannot connect to database', $
            name=run.logger_name, /error
    goto, done
  endif

  db = ucomp_db_connect(filename, section, $
                        status=status, logger_name=run.logger_name)
  if (status eq 0) then goto, done

  obsday_index = ucomp_db_obsday_insert(run.date, db, $
                                        status=status, $
                                        logger_name=run.logger_name)
  if (status ne 0L) then return

  tables = 'ucomp_' + ['raw', 'file', 'eng', 'sci', 'cal']
  for t = 0L, n_elements(tables) - 1L do begin
    ucomp_db_cleartable, obsday_index, tables[t], db, $
                         logger_name=run.logger_name
  endfor
  
  done:
  if (arg_present(db)) then obj_destroy, db
end
