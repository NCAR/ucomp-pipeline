; docformat = 'rst'

;+
; Run the UCoMP pipeline; this is full reprocessing for a day not the
; quicklook/realtime processing.
;
; :Params:
;   date : in, required, type=string
;     date to process in the form "YYYYMMDD"
;   config_filename : in, required, type=string
;     filename for configuration file to use
;-
pro ucomp_reprocess_wrapper, date, config_filename
  compile_opt strictarr

  ; initialize performance metrics
  t0 = systime(/seconds)
  start_memory = memory(/current)

  orig_except = !except
  !except = 0

  mode = 'eod'
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
  run = ucomp_run(date, mode, config_fullpath, /reprocess)
  if (~obj_valid(run)) then begin
    mg_log, 'cannot create run object', name=logger_name, /critical
    goto, done
  endif
  run.t0 = t0
  run->start_profiler

  ; log starting up pipeline with versions
  version = ucomp_version(revision=revision, branch=branch)
  mg_log, 'ucomp-pipeline %s (%s) [%s]', version, revision, branch, $
          name=run.logger_name, /info
  mg_log, 'using IDL %s on %s (%s)', $
          !version.release, !version.os_name, mg_hostname(), $
          name=run.logger_name, /debug

  mg_log, 'starting reprocessing for %d...', date, name=run.logger_name, /info

  ucomp_pipeline_step, 'ucomp_reprocess_cleanup', is_available=is_available, run=run
  if (~is_available) then begin
    mg_log, 'not available for reprocessing', name=run.logger_name, /warn
    goto, done
  endif

  ; copy config file to processing dir, creating dir if needed
  process_dir = filepath(date, root=run->config('processing/basedir'))
  ucomp_mkdir, process_dir, logger_name=run.logger_name

  file_copy, config_filename, $
             filepath(string(date, format='(%"%s.ucomp.cfg")'), $
                      root=process_dir), $
             /overwrite

  run->lock, is_available=is_available
  if (~is_available) then goto, done


  ; wave regions to process
  wave_regions = run->config('options/wave_regions')


  ; do the end-of-day processing
  ucomp_eod_steps, wave_regions, run=run


  ;== finish bookkeeping

  if (run->config('database/update')) then begin
    ucomp_pipeline_step, 'ucomp_db_update', run=run
  endif else begin
    mg_log, 'skipping updating database', name=logger_name, /info
  endelse

  ucomp_pipeline_step, 'ucomp_get_observerlog', run=run

  for w = 0L, n_elements(wave_regions) - 1L do begin
    ucomp_pipeline_step, 'ucomp_l1_archive', wave_regions[w], run=run
    ucomp_pipeline_step, 'ucomp_l1_publish', wave_regions[w], run=run
    ucomp_pipeline_step, 'ucomp_l2_archive', wave_regions[w], run=run
    ucomp_pipeline_step, 'ucomp_l2_publish', wave_regions[w], run=run
  endfor

  ucomp_pipeline_step, 'ucomp_quicklooks_publish', run=run
  ucomp_pipeline_step, 'ucomp_catalogs_publish', run=run

  ucomp_pipeline_step, 'ucomp_send_notification', run=run


  ;== cleanup and quit
  done:

  mg_log, /check_math, name=logger_name, /debug

  ; unlock raw directory and mark processed if no crash
  if (obj_valid(run)) then begin
    ; only unlock if this process was responsible for locking it
    if (keyword_set(is_available)) then run->unlock, mark_processed=error eq 0

    run->report
    run->report_profiling
  endif

  t1 = systime(/seconds)
  mg_log, 'total running time: %s', ucomp_sec2str(t1 - t0), $
          name=logger_name, /info

  if (obj_valid(run)) then obj_destroy, run
  mg_log, /quit

  !except = orig_except
end
