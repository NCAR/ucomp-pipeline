; docformat = 'rst'

;+
; Database activity at the beginning of a process run, i.e., updating
; ucomp_process to show the date is being processed.
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_db_startup, run=run
  compile_opt strictarr

  mg_log, 'updating database for start of processing...', $
          name=run.logger_name, /info

  ; connect to the database
  db = ucomp_db_connect(run->config('database/config_filename'), $
                        run->config('database/config_section'), $
                        logger_name=run.logger_name, $
                        log_statements=run->config('database/log_statements'), $
                        status=status)
  if (status ne 0) then goto, done

  ; get the observing day index for the date
  obsday_index = ucomp_db_obsday_insert(run.date, db, $
                                        status=status, $
                                        logger_name=run.logger_name)
  if (status ne 0L) then goto, done

  ucomp_db_set_process, 'processing', obsday_index, db, $
                        status=status, logger_name=run.logger_name

  done:
  if (obj_valid(db)) then obj_destroy, db
  mg_log, 'done', name=run.logger_name, /info
end
