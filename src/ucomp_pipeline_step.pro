; docformat = 'rst'

;+
; Wrapper routine to log, time, etc. each step of the pipeline.
;
; :Params:
;   routine_name : in, required, type=string
;     name of routine to call as a string
;   wave_type : in, optional, type=string
;     wave type, e.g., '1074', '1079', etc.
;
; :Keywords:
;   skip : in, optional, type=boolean
;     set to skip routine
;   _extra : in, optional, type=keywords
;     keywords to pass along to `ROUTINE`
;-
pro ucomp_pipeline_step, routine_name, wave_type, skip=skip, _extra=e
  compile_opt strictarr

  if (keyword_set(skip)) then begin
    mg_log, 'skipping %s', routine_name, from=routine_name, name='ucomp', /info
  endif else begin
    mg_log, 'starting %s...', routine_name, $
            from=routine_name, name='ucomp', /info

    start_memory = memory(/current)

    t0 = systime(/seconds)
    if (n_params() eq 1) then begin
      call_procedure, routine_name, _extra=e
    endif else begin
      call_procedure, routine_name, wave_type, _extra=e
    endelse
    t1 = systime(/seconds)

    mg_log, 'wall time: %s', ucomp_sec2str(t1 - t0), $
            from=routine_name, name='ucomp', /debug 
    mg_log, 'memory usage: %0.1fM', $
            (memory(/highwater) - start_memory) / 1024. / 1024., $
            from=routine_name, name='ucomp', /debug
    mg_log, 'done with %s', routine_name, $
            from=routine_name, name='ucomp', /info
  endelse
end
