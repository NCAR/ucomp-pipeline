; docformat = 'rst'

;+
; Wrapper routine to log, time, etc. each step of the L1 processing of a file.
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
pro ucomp_l1_step, routine_name, wave_type, skip=skip, _extra=e
  compile_opt strictarr

  if (keyword_set(skip)) then begin
    mg_log, 'skipping %s', routine_name, from=routine_name, name='ucomp', /info
  endif else begin
    mg_log, 'starting %s...', routine_name, $
            from=routine_name, name='ucomp', /info

    if (n_params() eq 1) then begin
      call_procedure, routine_name, _extra=e
    endif else begin
      call_procedure, routine_name, wave_type, _extra=e
    endelse

    mg_log, 'done with %s', routine_name, $
            from=routine_name, name='ucomp', /info
  endelse
end
