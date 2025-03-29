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
;   _ref_extra : in, optional, type=keywords
;     keywords to pass along to `ROUTINE`
;-
pro ucomp_pipeline_step, routine_name, wave_region, skip=skip, run=run, _ref_extra=e
  compile_opt strictarr

  if (keyword_set(skip)) then begin
    mg_log, 'skipping %s', routine_name, $
            from=routine_name, name=run.logger_name, /info
  endif else begin
    if ((n_elements(wave_region) gt 0L) && (size(wave_region, /type) eq 7)) then begin
      if (ucomp_isinteger(wave_region)) then begin
        mg_log, 'starting for %s nm...', wave_region, $
                from=routine_name, name=run.logger_name, /info
      endif else begin
        mg_log, 'starting for %s...', wave_region, from=routine_name, name=run.logger_name, /info
      endelse
    endif else begin
      mg_log, 'starting...', from=routine_name, name=run.logger_name, /info
    endelse

    start_memory = memory(/current)

    clock_id = run->start(routine_name)

    if (n_params() eq 1) then begin
      call_procedure, routine_name, run=run, _extra=e
    endif else begin
      call_procedure, routine_name, wave_region, run=run, _extra=e
    endelse

    time = run->stop(clock_id)
    run->log_memory, routine_name

    mg_log, /check_math, from=routine_name, name=run.logger_name, /debug

    memory_usage = (memory(/highwater) - start_memory) / 1024.0 / 1024.0
    mg_log, 'done (%s) [memory usage: %0.1fM]', $
            ucomp_sec2str(time), memory_usage, $
            from=routine_name, name=run.logger_name, /info
  endelse
end
