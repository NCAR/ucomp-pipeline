; docformat = 'rst'

;+
; Default raw data repair routine that does not change the data/headers in any
; way.
;
; :Params:
;   primary_header : in, out, required, type=strarr(n_keywords)
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_exts)"
;     extension data
;   ext_headers : in, out, required, type="strarr(n_keywords, n_exts)"
;     extension headers
;-
pro ucomp_data_default, primary_header, ext_data, ext_headers
  compile_opt strictarr

  ; no repair needed by default
end
