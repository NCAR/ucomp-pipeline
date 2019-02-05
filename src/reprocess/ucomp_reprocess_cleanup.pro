; docformat = 'rst'

;+
; Do steps necessary for reprocessing, such as removing marked as processed,
; deleting archived files, clearing entries from the database, etc.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_reprocess_cleanup, run=run
  compile_opt strictarr

  mg_log, 'cleaning %s', run.date, name=run.logger_name, /info

  ; remove's lock file indicating the day was already processed
  run->unlock
  
  ucomp_db_clearday, run=run

  archive_basedir = run->config('results/archive_basedir')
  if (n_elements(archive_basedir) gt 0L) then begin
    ucomp_clearday, run.date, archive_basedir, 'archive', $
                    logger_name=run.logger_name
  endif
end
