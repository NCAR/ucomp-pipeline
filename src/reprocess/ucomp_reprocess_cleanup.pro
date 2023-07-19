; docformat = 'rst'

;+
; Do steps necessary for reprocessing, such as removing marked as processed,
; deleting archived files, clearing entries from the database, etc.
;
; :Keywords:
;   is_available : out, optional, type=boolean
;     set to a named variable to retrieve whether the reprocessing is available
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_reprocess_cleanup, is_available=is_available, run=run
  compile_opt strictarr

  mg_log, 'cleaning %s', run.date, name=run.logger_name, /info

  ; remove's lock file indicating the day was already processed
  run->unlock, /reprocess, is_available=is_available
  if (~is_available) then goto, done

  ; clear database of entries from the date
  ucomp_db_clearday, run=run

  ; completely remove process directory for the date
  date_dir = filepath(run.date, root=run->config('processing/basedir'))
  file_delete, date_dir, /recursive, /allow_nonexistent

  ; completely remove engineering directory for the date
  eng_dir = filepath('', $
                     subdir=ucomp_decompose_date(run.date), $
                     root=run->config('engineering/basedir'))
  file_delete, eng_dir, /recursive, /allow_nonexistent

  ; remove results that have been distributed for the date
  web_basedir = run->config('results/web_basedir')
  if (n_elements(web_basedir) gt 0L) then begin
    ucomp_clearday, run.date, web_basedir, 'web archive', $
                    logger_name=run.logger_name
  endif

  ; remove results that have been distributed for the date
  fullres_basedir = run->config('results/fullres_basedir')
  if (n_elements(fullres_basedir) gt 0L) then begin
    ucomp_clearday, run.date, fullres_basedir, 'fullres web archive', $
                    logger_name=run.logger_name
  endif

  done:
end
