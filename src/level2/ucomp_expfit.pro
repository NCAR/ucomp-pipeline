; docformat = 'rst'

;+
; Evaluate exponential function. `p` is the form `[a, b]` where
;
; $$y = a e^(-(x - 1) / b)$$
;
; :Returns:
;
; :Params:
;   r : in, required, type=fltarr
;     radius, in solar radii
;   coeffs : in, required, type=fltarr(2)
;     coefficients
;
; :Author:
;   MLSO Software Team
;-
function ucomp_expfit, r, coeffs
  compile_opt strictarr

  return, coeffs[0] * exp(- (r - 1.0) / coeffs[1])
end
