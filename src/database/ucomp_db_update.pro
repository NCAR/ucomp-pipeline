; docformat = 'rst'

;+
; Insert all the database entries for a given wave type for a run.
;
; :Params:
;   wave_region : in, required, type=string
;     wave type
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_db_update, run=run
  compile_opt strictarr

  mg_log, 'updating database...', name=run.logger_name, /info

  ; get the files for the given wave_region
  all_files = run->get_files(count=n_all_files)
  if (n_all_files eq 0L) then begin
    mg_log, 'no files to insert', name=run.logger_name, /info
    goto, done
  endif

  sci_files = run->get_files(data_type='sci', count=n_sci_files)
  if (n_sci_files eq 0L) then begin
    mg_log, 'no science files to insert', name=run.logger_name, /info
  endif

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

  ; insert a software entry, if needed
  sw_index = ucomp_db_sw_insert(db, $
                                status=status, $
                                logger_name=run.logger_name)

  ; insert records for files
  ucomp_db_raw_insert, all_files, obsday_index, db, $
                       logger_name=run.logger_name
  ucomp_db_file_insert, sci_files, obsday_index, sw_index, db, $
                        logger_name=run.logger_name
  ; TODO: update ucomp_eng
  ; TODO: update ucomp_cal
  ; TODO: update ucomp_sci

  done:
  if (obj_valid(db)) then obj_destroy, db
  mg_log, 'done', name=run.logger_name, /info
end
