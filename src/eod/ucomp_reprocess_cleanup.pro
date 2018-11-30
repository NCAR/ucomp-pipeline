; docformat = 'rst'

;+
; Do steps necessary for reprocessing, such as removing marked as processed,
; deleting archived files, etc.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_reprocess_cleanup, run=run
  compile_opt strictarr

  mg_log, 'cleaning %s', run.date, name=run.logger_name, /info

  run->unlock
end
