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
  if (run->config('database/update') && run->config('eod/reprocess')) then begin
    mg_log, 'clearing database for the day', name=run.logger_name, /info

    db = ucomp_db_connect(run->config('database/config_filename'), $
                          run->config('database/config_section'), $
                          status=status, $
                          logger_name=run.logger_name)
    if (status ne 0L) then return

    obsday_index = ucomp_obsday_insert(run.date, db, $
                                       status=status, $
                                       logger_name=run.logger_name)
    if (status ne 0L) then return

;      kcor_db_clearday, run=run, $
;                        database=db, $
;                        obsday_index=obsday_index, $
;                        log_name='kcor/reprocess'

    obj_destroy, db
  endif else begin
    mg_log, 'skipping updating database', name=run.logger_name, /info
  endelse

end
