; docformat = 'rst'

;+
; Convert an index to a NUC value.
;
; :Returns:
;   string
;
; :Params:
;   index : in, required, type=long
;     NUC index
;
; :Keywords:
;   values : in, required, type=strarr
;     available NUC values
;-
function ucomp_index2nuc, index, values=values
  compile_opt strictarr

  return, index eq -1 ? 'invalid' : values[index]
end
