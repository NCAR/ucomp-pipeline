; docformat = 'rst'

;+
; Create the database plots for the given date.
;
; :Params:
;   date : in, required, type=string
;     date to process in the form "YYYYMMDD"
;   config_filename : in, required, type=string
;     filename for configuration file to use
;-
pro ucomp_db_update_wrapper, date, config_filename
  compile_opt strictarr

  ; initialize performance metrics
  t0 = systime(/seconds)
  start_memory = memory(/current)

  orig_except = !except
  !except = 0

  is_available = 0B
  mode = 'eod'
  logger_name = string(mode, format='(%"ucomp/%s")')

  processed = 0B

  ; error handler
  catch, error
  if (error ne 0) then begin
    catch, /cancel
    mg_log, /last_error, name=logger_name, /critical
    ucomp_crash_notification, run=run
    goto, done
  endif

  if (n_params() ne 2) then begin
    mg_log, 'incorrect number of arguments', name=logger_name, /critical
    goto, done
  endif

  config_fullpath = file_expand_path(config_filename)
  if (~file_test(config_fullpath, /regular)) then begin
    mg_log, 'config file %s not found', config_fullpath, $
            name=logger_name, /critical
    goto, done
  endif

  ;== initialize

  ; create run object
  run = ucomp_run(date, mode, config_fullpath)
  if (~obj_valid(run)) then begin
    mg_log, 'cannot create run object', name=logger_name, /critical
    goto, done
  endif
  run.t0 = t0
  run->start_profiler

  ; log starting up pipeline with versions
  mg_log, '------------------------------', name=run.logger_name, /info
  version = ucomp_version(revision=revision, branch=branch)
  mg_log, 'ucomp-pipeline %s (%s) [%s]', version, revision, branch, $
          name=run.logger_name, /info
  mg_log, 'using IDL %s on %s (%s)', $
          !version.release, !version.os_name, mg_hostname(), $
          name=run.logger_name, /debug

  mg_log, 'starting to create database plots for %d...', date, $
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

  ; insert a software entry, if needed
  sw_index = ucomp_db_sw_insert(db, $
                                status=status, $
                                logger_name=run.logger_name)

  ucomp_db_update_mlso_numfiles, obsday_index, db, run=run

  ucomp_rolling_dark_plots, db, run=run

  wave_regions = run->config('options/wave_regions')
  for w = 0L, n_elements(wave_regions) - 1L do begin
    ; make images/plots from database data

    ucomp_rolling_flat_plots, wave_regions[w], db, run=run

    ucomp_mission_background_plot, wave_regions[w], db, run=run
    ucomp_mission_image_scale_plot, wave_regions[w], db, run=run
    ucomp_mission_vcrosstalk_plot, wave_regions[w], db, run=run
    ucomp_mission_centering_plot, wave_regions[w], db, run=run
    ucomp_mission_eccentricity_plot, wave_regions[w], db, run=run

    ucomp_rolling_synoptic_map, wave_regions[w], $
                                'intensity', 'int', 'intensity', $
                                1.08, 'r108i', $
                                db, run=run
    ucomp_rolling_synoptic_map, wave_regions[w], $
                                'intensity', 'int', 'intensity', $
                                1.3, 'r13i', $
                                db, run=run
    ucomp_rolling_synoptic_map, wave_regions[w], $
                                'linear polarization', 'linpol', 'linpol', $
                                1.08, 'r108l', $
                                db, run=run
    ucomp_rolling_synoptic_map, wave_regions[w], $
                                'linear polarization', 'linpol', 'linpol', $
                                1.3, 'r13l', $
                                db, run=run
    ucomp_rolling_synoptic_map, wave_regions[w], $
                                'radial azimuth', 'radazi', 'radial_azimuth', $
                                1.08, 'r108radazi', $
                                db, run=run
    ucomp_rolling_synoptic_map, wave_regions[w], $
                                'radial azimith', 'radazi', 'radial_azimuth', $
                                1.3, 'r13radazi', $
                                db, run=run

    ucomp_rolling_synoptic_map, wave_regions[w], $
                                'doppler velocity', 'doppler', 'doppler', $
                                1.08, 'r108doppler', $
                                db, run=run
    ucomp_rolling_synoptic_map, wave_regions[w], $
                                'doppler velocity', 'doppler', 'doppler', $
                                1.3, 'r13doppler', $
                                db, run=run

    ucomp_plot_eccentricity, wave_regions[w], obsday_index, db, run=run
  endfor

  done:
  if (obj_valid(db)) then obj_destroy, db
  mg_log, 'done', name=run.logger_name, /info

  mg_log, /check_math, name=logger_name, /debug

  t1 = systime(/seconds)
  mg_log, 'total running time: %s', ucomp_sec2str(t1 - t0), $
          name=logger_name, /info

  if (obj_valid(run)) then obj_destroy, run
  mg_log, /quit

  !except = orig_except
end
