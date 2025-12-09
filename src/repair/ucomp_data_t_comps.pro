; docformat = 'rst'

;+
; Fix up the T_COMPS FITS keyword.
;
; :Params:
;   primary_header : in, out, required, type=strarr(n_keywords)
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_exts)"
;     extension data
;   ext_headers : in, out, required, type="strarr(n_keywords, n_exts)"
;     extension headers
;-
pro ucomp_data_t_comps, primary_header, ext_data, ext_headers
  compile_opt strictarr

  ocomment = '[TF] Lyot turning temperature compensation on'
  ucomp_addpar, primary_header, 'T_COMPS', boolean(1), comment=comment
end
