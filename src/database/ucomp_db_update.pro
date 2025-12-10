; docformat = 'rst'

;+
; Insert all the database entries for a given wave type for a run.
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_db_update, run=run
  compile_opt strictarr

  mg_log, 'updating database...', name=run.logger_name, /info

  all_files = run->get_files(count=n_all_files)
  if (n_all_files eq 0L) then begin
    mg_log, 'no files to insert', name=run.logger_name, /info
    goto, done
  endif

  dark_files = run->get_files(data_type='dark', count=n_dark_files)
  cal_files = run->get_files(data_type='cal', count=n_cal_files)

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

  ucomp_db_cal_insert, dark_files, 'dark', $
                       obsday_index, sw_index, $
                       database=db, $
                       logger_name=run.logger_name
  ucomp_db_cal_insert, cal_files, 'cal', $
                       obsday_index, sw_index, $
                       database=db, $
                       logger_name=run.logger_name

  wave_regions = run->config('options/wave_regions')

  for w = 0L, n_elements(wave_regions) - 1L do begin
    flat_files = run->get_files(data_type='flat', wave_region=wave_regions[w], $
                                count=n_flat_files)
    ucomp_db_cal_insert, flat_files, 'flat', $
                         obsday_index, sw_index, wave_regions[w], $
                         database=db, $
                         logger_name=run.logger_name, run=run
  endfor

  ucomp_db_update_mlso_numfiles, obsday_index, db, run=run

  ucomp_rolling_dark_plots, db, run=run

  for w = 0L, n_elements(wave_regions) - 1L do begin
    sci_files = run->get_files(data_type='sci', wave_region=wave_regions[w], $
                               count=n_sci_files)

    ucomp_db_file_insert, sci_files, 'L1', 'IQUV', $
                          obsday_index, sw_index, db, $
                          logger_name=run.logger_name
    ucomp_db_file_insert, sci_files, 'L1', 'intensity', $
                          obsday_index, sw_index, db, $
                          logger_name=run.logger_name
    ucomp_db_sci_insert, sci_files, wave_regions[w], $
                         obsday_index, sw_index, db, run=run

    ; level 2 files
    ucomp_db_file_insert, sci_files, 'L2', 'L2 file', $
                          obsday_index, sw_index, db, $
                          logger_name=run.logger_name

    ucomp_db_l2_average_insert, wave_regions[w], obsday_index, sw_index, db, $
                                run=run

    ; make images/plots from database data
    n_rolling_days = 28L

    ucomp_rolling_flat_plots, wave_regions[w], db, run=run
    ucomp_rolling_o1focus_plot, wave_regions[w], db, $
                                n_days=n_rolling_days, run=run

    ucomp_mission_background_plot, wave_regions[w], db, run=run
    ucomp_mission_image_scale_plot, wave_regions[w], db, run=run
    ucomp_mission_vcrosstalk_plot, wave_regions[w], db, run=run
    ucomp_mission_centering_plot, wave_regions[w], db, run=run
    ucomp_mission_eccentricity_plot, wave_regions[w], db, run=run
    ucomp_rolling_o1focus_plot, wave_regions[w], db, /mission, run=run

    smoothing = [0B, 1B]

    for s = 0L, n_elements(smoothing) - 1L do begin
      ucomp_rolling_synoptic_map, wave_regions[w], $
                                  'intensity', 'int', 'intensity', $
                                  1.08, 'r108i', $
                                  db, $
                                  n_days=n_rolling_days, smooth=smoothing[s], $
                                  run=run
      ucomp_rolling_synoptic_map, wave_regions[w], $
                                  'intensity', 'int', 'intensity', $
                                  1.3, 'r13i', $
                                  db, $
                                  n_days=n_rolling_days, smooth=smoothing[s], $
                                  run=run

      ucomp_rolling_synoptic_map, wave_regions[w], $
                                  'linear polarization', 'linpol', 'linpol', $
                                  1.08, 'r108l', $
                                  db, $
                                  n_days=n_rolling_days, smooth=smoothing[s], $
                                  run=run
      ucomp_rolling_synoptic_map, wave_regions[w], $
                                  'linear polarization', 'linpol', 'linpol', $
                                  1.3, 'r13l', $
                                  db, $
                                  n_days=n_rolling_days, smooth=smoothing[s], $
                                  run=run

      ucomp_rolling_synoptic_map, wave_regions[w], $
                                  'radial azimuth', 'radazi', 'radial_azimuth', $
                                  1.08, 'r108radazi', $
                                  db, $
                                  n_days=n_rolling_days, smooth=smoothing[s], $
                                  run=run
      ucomp_rolling_synoptic_map, wave_regions[w], $
                                  'radial azimith', 'radazi', 'radial_azimuth', $
                                  1.3, 'r13radazi', $
                                  db, $
                                  n_days=n_rolling_days, smooth=smoothing[s], $
                                  run=run

      ucomp_rolling_synoptic_map, wave_regions[w], $
                                  'doppler velocity', 'doppler', 'doppler', $
                                  1.08, 'r108doppler', $
                                  db, $
                                  n_days=n_rolling_days, smooth=smoothing[s], $
                                  run=run
      ucomp_rolling_synoptic_map, wave_regions[w], $
                                  'doppler velocity', 'doppler', 'doppler', $
                                  1.3, 'r13doppler', $
                                  db, $
                                  n_days=n_rolling_days, smooth=smoothing[s], $
                                  run=run
    endfor

    ucomp_daily_o1focus_plot, wave_regions[w], obsday_index, db, run=run
    ucomp_daily_eccentricity_plot, wave_regions[w], obsday_index, db, run=run
  endfor

  done:
  if (obj_valid(db)) then obj_destroy, db
  mg_log, 'done', name=run.logger_name, /info
end
