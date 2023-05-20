; docformat = 'rst'

;+
; Tick format to use for plotting DN values.
;
; :Returns:
;   formatted string representing a tick mark
;
; :Params:
;   axis : in, required, type=integer
;     axis number: 0 for x-axis, 1 for y-axis, 2 for z-axis
;   index : in, required, type=integer
;     tick mark index (indices start at 0)
;   value : in, required, type=float
;     tick value to format
;-
function ucomp_dn_format, axis, index, value
  compile_opt strictarr

  return, mg_float2str(long(value), places_sep=',')
end
