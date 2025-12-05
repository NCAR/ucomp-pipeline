; docformat = 'rst'

;+
; Convert NUC value to index.
;
; :Returns:
;   long
;
; :Params:
;   nuc : in, required, type=string
;     NUC value, e.g., "normal" or "Offset + gain corrected"
;
; :Keywords:
;   values : in, required, type=strarr
;     available NUC values
;-
function ucomp_nuc2index, nuc, values=values
  compile_opt strictarr

  indices = where(nuc eq values, count)
  return, indices[0]
end
