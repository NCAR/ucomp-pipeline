; docformat = 'rst'

;+
; Combine cameras.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_combine_cameras, file, primary_header, ext_data, ext_headers, run=run
  compile_opt strictarr

  ; TODO: average combined "cameras", now we are just taking "camera 0"
  ;ext_data = reform(ext_data[*, *, *, 0, *])
  ; TODO: implement
  mg_log, 'not implemented', name=run.logger, /warn
end
