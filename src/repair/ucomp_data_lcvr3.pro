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

  temp_value = ucomp_getpar(primary_header, 'T_LCVR3')
  ucomp_addpar, primary_header, 'T_LCVR3', temp_value, $
                comment='[C] Lyot LCVR3 Temp'

  temp_value = ucomp_getpar(primary_header, 'TU_LCVR3')
  ucomp_addpar, primary_header, 'TU_LCVR3', temp_value, $
                comment='[C] Lyot LCVR3 Temp Unfiltered'
end
