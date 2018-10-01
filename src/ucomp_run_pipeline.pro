; docformat = 'rst'

;+
; Run the UCoMP pipeline.
;
; :Params:
;   date : in, required, type=string
;     date to process in the form "YYYYMMDD"
;   config_filename : in, required, type=string
;     filename for configuration file to use
;-
pro ucomp_run_pipeline, date, config_filename
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
    mg_log, /last_error, name='ucomp', /critical
    goto, done
  endif

  if (n_params() ne 2) then begin
    mg_log, 'incorrect number of arguments', name='ucomp', /critical
    goto, done
  endif

  config_fullpath = file_expand_path(config_filename)
  if (~file_test(config_fullpath, /regular)) then begin
    mg_log, config_fullpath, format='(%"config file %s not found")', $
            name='ucomp', /critical
    goto, done
  endif

  ; create run object
  run = ucomp_run(date, config_fullpath)
  if (~obj_valid(run)) then begin
    mg_log, 'cannot create run object', name='ucomp', /critical
    goto, done
  endif
  run.t0 = t0

  wave_types = run->config('options/wave_types')

  version = ucomp_version(revision=revision, branch=branch)
  mg_log, 'ucomp-pipeline %s (%s on %s)', version, revision, branch, $
          name='ucomp', /info
  mg_log, 'using IDL %s on %s', !version.release, !version.os_name, $
          name='ucomp', /info

  mg_log, 'starting processing for %d...', date, name='ucomp', /info

  ;== level 1

  run->lock, is_available=is_available
  if (~is_available) then goto, done

  ucomp_pipeline_step, 'ucomp_make_raw_inventory', run=run

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

  mg_log, /check_math, name='ucomp', /debug

  ; unlock raw directory and mark processed if no crash
  if (obj_valid(run)) then run->unlock, error

  t1 = systime(/seconds)
  mg_log, 'total running time: %s', ucomp_sec2str(t1 - t0), $
          name='ucomp', /info

  if (obj_valid(run)) then obj_destroy, run
  mg_log, /quit

  !except = orig_except
end
