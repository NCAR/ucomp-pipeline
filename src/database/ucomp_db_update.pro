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
pro ucomp_db_update, wave_region, run=run
  compile_opt strictarr

  mg_log, 'updating database for %s nm...', wave_region, $
          name=run.logger_name, /info

  ; get the files for the given wave_region
  files = run->get_files(wave_region=wave_region, count=n_files)
  if (n_files eq 0L) then begin
    mg_log, 'no files to insert', name=run.logger_name, /info
    goto, done
  endif

  sci_files = run->get_files(data_type='sci', wave_region=wave_region, $
                             count=n_sci_files)
  if (n_sci_files eq 0L) then begin
    mg_log, 'no science files to insert', name=run.logger_name, /info
  endif

  ; connect to the database
  db = ucomp_db_connect(run->config('database/config_filename'), $
                        run->config('database/config_section'), $
                        status=status, $
                        error_message=error_message)
  if (status eq 0) then begin
    db->getProperty, host_name=host
    mg_log, 'connected to %s', host, name=run.logger_name, /info
  endif else begin
    mg_log, 'failed to connect to database', name=run.logger_name, /error
    mg_log, error_message, name=run.logger_name, /error
    goto, done
  endelse

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
  ucomp_db_raw_insert, files, obsday_index, db, $
                       logger_name=run.logger_name
  ucomp_db_file_insert, sci_files, obsday_index, sw_index, db, $
                        logger_name=run.logger_name

  done:
  if (obj_valid(db)) then obj_destroy, db
  mg_log, 'done', name=run.logger_name, /info
end
