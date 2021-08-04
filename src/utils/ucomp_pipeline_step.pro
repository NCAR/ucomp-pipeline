; docformat = 'rst'

;+
; Wrapper routine to log, time, etc. each step of the pipeline.
;
; :Params:
;   routine_name : in, required, type=string
;     name of routine to call as a string
;   wave_region : in, optional, type=string
;     wave type, e.g., '1074', '1079', etc.
;
; :Keywords:
;   skip : in, optional, type=boolean
;     set to skip routine
;   run : in, required, type=object
;     UCoMP run object
;   _extra : in, optional, type=keywords
;     keywords to pass along to `ROUTINE`
;-
pro ucomp_pipeline_step, routine_name, wave_region, skip=skip, run=run, _ref_extra=e
  compile_opt strictarr

  if (keyword_set(skip)) then begin
    mg_log, 'skipping %s', routine_name, $
            from=routine_name, name=run.logger_name, /info
  endif else begin
    mg_log, 'starting...', from=routine_name, name=run.logger_name, /info

    start_memory = memory(/current)

    clock_id = run->start(routine_name)

    if (n_params() eq 1) then begin
      call_procedure, routine_name, run=run, _extra=e
    endif else begin
      call_procedure, routine_name, wave_region, run=run, _extra=e
    endelse

    time = run->stop(clock_id)

    mg_log, /check_math, from=routine_name, name=run.logger_name, /warn

    mg_log, 'memory usage: %0.1fM', $
            (memory(/highwater) - start_memory) / 1024. / 1024., $
            from=routine_name, name=run.logger_name, /debug
    mg_log, 'done (%s)', ucomp_sec2str(time), $
            from=routine_name, name=run.logger_name, /info
  endelse
end
