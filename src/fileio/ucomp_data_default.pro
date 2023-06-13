; docformat = 'rst'

;+
; Raw data repair routine that fixes the comments for {T,TU}_LCVR3.
;
; :Params:
;   primary_header : in, out, required, type=strarr(n_keywords)
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_exts)"
;     extension data
;   ext_headers : in, out, required, type="strarr(n_keywords, n_exts)"
;     extension headers
;-
pro ucomp_data_lcvr3, primary_header, ext_data, ext_headers
  compile_opt strictarr

  for e = 0L, n_elements(ext_headers) - 1L do begin
    h = ext_headers[e]

    temp = ucomp_getpar(h, 'T_LCVR3')
    ucomp_addpar, h, 'T_LCVR3', comment='[C] Lyot LCVR3 Temp'
    temp = ucomp_getpar(h, 'TU_LCVR3')
    ucomp_addpar, h, 'TU_LCVR3', comment='[C] Lyot LCVR3 Temp Unfiltered'

    ext_headers[e] = h
  endfor
end
