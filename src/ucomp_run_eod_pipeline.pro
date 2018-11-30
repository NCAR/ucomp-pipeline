; docformat = 'rst'

;+
; Run the UCoMP pipeline; this is full processing (or reprocessing) for a day
; not the quicklook/realtime processing.
;
; :Params:
;   date : in, required, type=string
;     date to process in the form "YYYYMMDD"
;   config_filename : in, required, type=string
;     filename for configuration file to use
;-
pro ucomp_run_eod_pipeline, date, config_filename
  compile_opt strictarr

  ; initialize performance metrics
  t0 = systime(/seconds)
  start_memory = memory(/current)

  orig_except = !except
  !except = 0

  ; error handler
  catch, error
  if (error ne 0) then begin
    catch, /cancel
    mg_log, /last_error, name='ucomp/eod', /critical
    goto, done
  endif

  if (n_params() ne 2) then begin
    mg_log, 'incorrect number of arguments', name='ucomp/eod', /critical
    goto, done
  endif

  config_fullpath = file_expand_path(config_filename)
  if (~file_test(config_fullpath, /regular)) then begin
    mg_log, config_fullpath, format='(%"config file %s not found")', $
            name='ucomp/eod', /critical
    goto, done
  endif

  ; create run object
  run = ucomp_run(date, 'eod', config_fullpath)
  if (~obj_valid(run)) then begin
    mg_log, 'cannot create run object', name='ucomp/eod', /critical
    goto, done
  endif
  run.t0 = t0
  run->start_profiler

  ; log starting up pipeline with versions
  version = ucomp_version(revision=revision, branch=branch)
  mg_log, 'ucomp-pipeline %s (%s on %s)', version, revision, branch, $
          name=run.logger_name, /info
  mg_log, 'using IDL %s on %s', !version.release, !version.os_name, $
          name=run.logger_name, /info

  mg_log, 'starting processing for %d...', date, name=run.logger_name, /info

  if (run->config('eod/reprocessing')) then begin
    ucomp_reprocess_cleanup, run=run
  endif

  ; copy config file to processing dir, creating dir if needed
  process_dir = filepath(date, root=run->config('processing/basedir'))
  if (~file_test(process_dir, /directory)) then file_mkdir, process_dir
  file_copy, config_filename, $
             filepath(string(date, format='(%"%s.ucomp.cfg")'), $
                      root=process_dir), $
             /overwrite


  ;== level 1

  run->lock, is_available=is_available
  if (~is_available) then goto, done

  ucomp_pipeline_step, 'ucomp_make_raw_inventory', run=run

  wave_types = run->config('options/wave_types')
  for w = 0L, n_elements(wave_types) - 1L do begin
    ucomp_pipeline_step, 'ucomp_check_quality', wave_types[w], run=run
    ucomp_pipeline_step, 'ucomp_make_darks', wave_types[w], run=run
    ucomp_pipeline_step, 'ucomp_make_flats', wave_types[w], run=run
    ucomp_pipeline_step, 'ucomp_l1_process', wave_types[w], run=run
    ucomp_pipeline_step, 'ucomp_check_gbu', wave_types[w], run=run
  endfor


  ;== level 2

  ; TODO: add level 2 steps


  ; finish bookkeeping

  for w = 0L, n_elements(wave_types) - 1L do begin
    ucomp_pipeline_step, 'ucomp_update_database', wave_types[w], run=run
  endfor

  ucomp_pipeline_step, 'ucomp_send_notification', run=run


  ;== cleanup and quit
  done:

  mg_log, /check_math, name=run.logger_name, /debug

  ; unlock raw directory and mark processed if no crash
  if (obj_valid(run)) then run->unlock, mark_processed=error eq 0

  run->report
  run->report_profiling

  t1 = systime(/seconds)
  mg_log, 'total running time: %s', ucomp_sec2str(t1 - t0), $
          name=run.logger_name, /info

  if (obj_valid(run)) then obj_destroy, run
  mg_log, /quit

  !except = orig_except
end
