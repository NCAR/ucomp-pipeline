; docformat = 'rst'

;+
; Change units on LCVRELX comment from "[ms]" to "[s]".
;
; :Params:
;   primary_header : in, out, required, type=strarr(n_keywords)
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_exts)"
;     extension data
;   ext_headers : in, out, required, type="strarr(n_keywords, n_exts)"
;     extension headers
;-
pro ucomp_data_lcvrelx, primary_header, ext_data, ext_headers
  compile_opt strictarr

  comment = '[s] delay after LCVR turning before data'

  lcvrelx_value = ucomp_getpar(primary_header, 'LCVRELX')
  ucomp_addpar, primary_header, 'LCVRELX', lcvrelx_value, comment=comment
end
