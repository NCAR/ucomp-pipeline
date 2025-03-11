; docformat = 'rst'

;+
; Wrapper routine to log, time, etc. each step of the L3 processing of an
; individual file.
;
; :Params:
;   routine_name : in, required, type=string
;     L1 step to apply
;
; :Keywords:
;   skip : in, optional, type=boolean
;     set to skip routine
;   run : in, required, type=object
;     UCoMP run object
;   _extra : in, optional, type=keywords
;     keywords to pass along to `routine_name`
;-
pro ucomp_l3_file_step, routine_name, $
                        skip=skip, run=run, _extra=e
  compile_opt strictarr
  on_error, 2

  if (keyword_set(skip)) then begin
    mg_log, 'skipping', from=routine_name, name=run.logger_name, /debug
  endif else begin
    mg_log, 'starting...', from=routine_name, name=run.logger_name, /debug

    clock_id = run->start(routine_name)
    call_procedure, routine_name, run=run, _extra=e
    time = run->stop(clock_id)
    run->log_memory, routine_name

    mg_log, /check_math, from=routine_name, name=run.logger_name, /debug

    mg_log, 'done (%s)', ucomp_sec2str(time), $
            from=routine_name, name=run.logger_name, /debug
  endelse
end
