; docformat = 'rst'

;+
; Run the realtime UCoMP pipeline.
;
; :Params:
;   date : in, required, type=string
;     date to process in the form "YYYYMMDD"
;   config_filename : in, required, type=string
;     filename for configuration file to use
;-
pro ucomp_realtime_wrapper, date, config_filename
  compile_opt strictarr

  ; initialize performance metrics
  t0 = systime(/seconds)
  start_memory = memory(/current)

  orig_except = !except
  !except = 0

  mode = 'realtime'
  logger_name = string(mode, format='(%"ucomp/%s")')

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

  ; log starting up pipeline with versions
  version = ucomp_version(revision=revision, branch=branch)
  mg_log, '------------------------------', name=run.logger_name, /info
  mg_log, 'ucomp-pipeline %s (%s) [%s]', version, revision, branch, $
          name=run.logger_name, /info
  mg_log, 'using IDL %s on %s (%s)', $
          !version.release, !version.os_name, mg_hostname(), $
          name=run.logger_name, /debug

  mg_log, 'starting processing for %d...', date, name=run.logger_name, /info

  processing_dir = filepath(run.date, root=run->config('processing/basedir'))
  ucomp_mkdir, processing_dir, logger_name=run.logger_name

  run->lock, is_available=is_available
  if (~is_available) then goto, done


  ; find new files
  l0_dir = filepath(run.date, root=run->config('raw/basedir'))
  catalog_filename = filepath(string(run.date, format='(%"%s.ucomp.catalog.txt")'), $
                              subdir=run.date, $
                              root=run->config('processing/basedir'))
  new_filenames = ucomp_new_files(l0_dir, catalog_filename, $
                                  count=n_new_files, error=error)

  case error of
    0: ; no error
    1: mg_log, 'no catalog file', name=run.logger_name, /info
    2: mg_log, 'files removed from raw dir (errno 2)', name=run.logger_name, /warn
    3: mg_log, 'files removed from raw dir (errno 3)', name=run.logger_name, /warn
    else: mg_log, 'unknown error', name=run.logger_name, /warn
  endcase

  mg_log, '%d new files', n_new_files, name=run.logger_name, /info
  for f = 0L, n_new_files - 1L do begin
    mg_log, 'found %s', new_filenames[f], name=run.logger_name, /debug
  endfor

  if (n_new_files gt 0L) then begin
    run->make_raw_inventory, new_filenames, $
                             n_extensions=n_extensions, $
                             data_types=data_types, $
                             exptimes=exptimes, $
                             gain_modes=gain_modes, $
                             wave_regions=wave_regions, $
                             n_points=n_points, $
                             numsum=numsum

    mg_log, 'updating catalog file...', name=run.logger_name, /info
    ucomp_update_catalog, catalog_filename, $
                          new_filenames, $
                          n_extensions, $
                          data_types, $
                          exptimes, $
                          gain_modes, $
                          wave_regions, $
                          n_points, $
                          numsum
  endif

  ;== create quicklook L0.5 files

  wave_regions = run->config('options/wave_regions')
  types = ['flat', 'cal', 'sci']   ; make sure to keep sci last for loop below
  for w = 0L, n_elements(wave_regions) - 1L do begin
    n_wave_files = 0L
    for t = 0L, n_elements(types) - 1L do begin
      files = run->get_files(data_type=types[t], $
                             wave_region=wave_regions[w], $
                             count=n_files)
      mg_log, '%d %s nm %s files', n_files, wave_regions[w], types[t], $
              name=run.logger_name, $
              info=n_files gt 0L, $
              debug=n_files eq 0L
      n_wave_files += n_files
    endfor

    if (n_wave_files eq 0L) then continue
    n_digits = floor(alog10(n_files)) + 1L

    for f = 0L, n_files - 1L do begin
      mg_log, mg_format('%*d/%d @ %s: %s', n_digits, /simple), $
              f + 1, n_files, wave_regions[w], file_basename(files[f].raw_filename), $
              name=run.logger_name, /info
      ucomp_pipeline_step, 'ucomp_quicklook', files[f], run=run
    endfor
    ucomp_pipeline_step, 'ucomp_rt_quicklook_distribute', files, run=run
  endfor


  ;== cleanup and quit
  done:

  mg_log, /check_math, name=logger_name, /debug

  ; unlock raw directory and mark processed if no crash
  if (obj_valid(run)) then begin
    ; only unlock if this process was responsible for locking it
    if (is_available) then run->unlock
  endif

  t1 = systime(/seconds)
  mg_log, 'total running time: %s', ucomp_sec2str(t1 - t0), $
          name=logger_name, /info

  if (obj_valid(run)) then obj_destroy, run
  mg_log, /quit

  !except = orig_except
end
