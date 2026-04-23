; docformat = 'rst'

;+
; Change OC-31 to OC-31A.
;
; :Params:
;   primary_header : in, out, required, type=strarr(n_keywords)
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_exts)"
;     extension data
;   ext_headers : in, out, required, type="strarr(n_keywords, n_exts)"
;     extension headers
;-
pro ucomp_data_oc31a, primary_header, ext_data, ext_headers
  compile_opt strictarr

  occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
  if (occulter_id eq '31') then begin
    ucomp_addpar, primary_header, 'OCCLTRID', '31A'
  endif
end
