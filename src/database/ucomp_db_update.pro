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

  dark_files = run->get_files(data_type='dark', count=n_dark_files)
  if (n_dark_files eq 0L) then begin
    mg_log, 'no dark files to insert', name=run.logger_name, /info
  endif
  flat_files = run->get_files(data_type='flat', count=n_flat_files)
  if (n_flat_files eq 0L) then begin
    mg_log, 'no flat files to insert', name=run.logger_name, /info
  endif
  cal_files = run->get_files(data_type='cal', count=n_cal_files)
  if (n_cal_files eq 0L) then begin
    mg_log, 'no cal files to insert', name=run.logger_name, /info
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

  ucomp_db_eng_insert, all_files, obsday_index, sw_index, db, $
                       logger_name=run.logger_name

  ucomp_db_cal_insert, dark_files, obsday_index, sw_index, db, $
                       logger_name=run.logger_name
  ucomp_db_cal_insert, flat_files, obsday_index, sw_index, db, $
                       logger_name=run.logger_name
  ucomp_db_cal_insert, cal_files, obsday_index, sw_index, db, $
                       logger_name=run.logger_name

  wave_regions = run->config('options/wave_regions')
  for w = 0L, n_elements(wave_regions) - 1L do begin
    sci_files = run->get_files(data_type='sci', wave_region=wave_regions[w], $
                               count=n_sci_files)
    if (n_sci_files eq 0L) then begin
      mg_log, 'no %s nm science files to insert', wave_regions[w], $
              name=run.logger_name, /info
    endif

    ucomp_db_file_insert, sci_files, obsday_index, sw_index, db, $
                          logger_name=run.logger_name
    ucomp_db_sci_insert, sci_files, obsday_index, sw_index, db, run=run

    ucomp_rolling_synoptic_map, wave_regions[w], 'intensity', 'int', 1.08, $
                                                 'r108i', db, run=run
    ucomp_rolling_synoptic_map, wave_regions[w], 'intensity', 'int', 1.3, $
                                                 'r13i', db, run=run
    ucomp_rolling_synoptic_map, wave_regions[w], 'linear polarization', $
                                                 'linpol', $
                                                 1.08, $
                                                 'r108l', $
                                                 db, $
                                                 run=run
    ucomp_rolling_synoptic_map, wave_regions[w], 'linear polarization', $
                                                 'linpol', $
                                                 1.3, $
                                                 'r13l', $
                                                 db, $
                                                 run=run
    ucomp_rolling_synoptic_map, wave_regions[w], 'radial azimuth', $
                                'radazi', $
                                1.08, $
                                'r108radazi', $
                                db, $
                                run=run
    ucomp_rolling_synoptic_map, wave_regions[w], 'radial azimith', $
                                'radazi', $
                                1.3, $
                                'r13radazi', $
                                db, $
                                run=run
    ucomp_rolling_synoptic_map, wave_regions[w], 'doppler velocity', $
                                'doppler', $
                                1.08, $
                                'r108doppler', $
                                db, $
                                run=run
    ucomp_rolling_synoptic_map, wave_regions[w], 'doppler velocity', $
                                'doppler', $
                                1.3, $
                                'r13doppler', $
                                db, $
                                run=run
  endfor

  done:
  if (obj_valid(db)) then obj_destroy, db
  mg_log, 'done', name=run.logger_name, /info
end
