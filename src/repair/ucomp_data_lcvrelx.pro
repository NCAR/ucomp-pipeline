; docformat = 'rst'

;+
; Change units on LCVRELX comment from "[ms]" to "[s]". This will create
; a null value keyword if LCVRELX is not present, which it wasn't early in the
; mission (introduced on 20220715).
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

  comment = '[s] delay after LCVR tuning before data'

  lcvrelx_value = ucomp_getpar(primary_header, 'LCVRELX', found=found)
  if (~found) then after = 'WAVOFF'

  ucomp_addpar, primary_header, 'LCVRELX', lcvrelx_value, $
                format='(F0.3)', $
                comment=comment, $
                after=after
end
