; docformat = 'rst'

;+
; Wrapper routine to log, time, etc. each step of the L1 processing of a file.
;
; :Params:
;   routine_name : in, required, type=string
;     L1 step to apply
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, nx, nexts)"
;     extension data
;   headers : in, requiredd, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   skip : in, optional, type=boolean
;     set to skip routine
;   run : in, required, type=object
;     UCoMP run object
;   _extra : in, optional, type=keywords
;     keywords to pass along to `ROUTINE`
;-
pro ucomp_l1_step, routine_name, file, primary_header, data, headers, $
                   skip=skip, run=run, _extra=e
  compile_opt strictarr

  if (keyword_set(skip)) then begin
    mg_log, 'skipping', from=routine_name, name=run.logger_name, /debug
  endif else begin
    mg_log, 'starting...', from=routine_name, name=run.logger_name, /debug

    clock_id = run->start(routine_name)
    call_procedure, routine_name, file, primary_header, data, headers, $
                    run=run, _extra=e
    time = run->stop(clock_id)

    mg_log, /check_math, name=run.logger_name, /warn

    mg_log, 'done (%s)', ucomp_sec2str(time), $
            from=routine_name, name=run.logger_name, /debug
  endelse
end
