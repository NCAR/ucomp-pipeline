; docformat = 'rst'

;+
; Perform polarimetric correction.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, ny, n_pol_states, nexts)"
;     extension data
;   headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_polarimetric_correction, file, primary_header, data, headers, run=run
  compile_opt strictarr

  ; TODO: implement
  ; call `UCOMP_POLARIMETRIC_TRANSFORM`
  mg_log, 'not implemented', name=run.logger, /warn
end
