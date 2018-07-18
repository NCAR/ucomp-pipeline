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

  config_filename_fullpath = file_expand_path(config_filename)

  ; initialize performance metrics
  t0 = systime(/seconds)
  start_memory = memory(/current)

  ; create run object
  run = ucomp_run(date, config_filename)

  version = ucomp_version(revision=revision, branch=branch)
  mg_log, 'ucomp-pipeline %s (%s on %s)', version, revision, branch, $
          name='ucomp', /info
  mg_log, 'using IDL %s on %s', !version.release, !version.os_name, $
          name='ucomp', /info
  mg_log, 'starting processing for %d', date, name='ucomp', /info

  ucomp_pipeline_step, 'ucomp_make_darks', run=run
  ucomp_pipeline_step, 'ucomp_make_flats', run=run

  done:
  t1 = systime(/seconds)
  mg_log, 'total running time: %s', ucomp_sec2str(t1 - t0), $
          name='ucomp', /info

  obj_destroy, run
  mg_log, /quit
end
