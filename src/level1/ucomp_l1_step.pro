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
;   _extra : in, optional, type=keywords
;     keywords to pass along to `ROUTINE`
;-
pro ucomp_l1_step, routine_name, file, primary_header, data, headers, skip=skip, _extra=e
  compile_opt strictarr

  if (keyword_set(skip)) then begin
    mg_log, 'skipping', from=routine_name, name='ucomp', /info
  endif else begin
    mg_log, 'starting...', from=routine_name, name='ucomp', /info

    call_procedure, routine_name, file, primary_header, data, headers, _extra=e

    mg_log, 'done', from=routine_name, name='ucomp', /info
  endelse
end
