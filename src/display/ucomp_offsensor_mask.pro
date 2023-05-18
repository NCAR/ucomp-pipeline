; docformat = 'rst'

;+
; Produce a mask of the pixels that are off-sensor but brought into the frame
; by the p-angle rotation.
;
; :Returns:
;   mask as a `bytarr(dims)` array
;
; :Params:
;   dims : in, required, type=lonarr(2)
;     dimensions of the mask to produce
;   p_angle : in, required, type=float
;     p-angle in degrees
;-
function ucomp_offsensor_mask, dims, p_angle
  compile_opt strictarr

  mask = bytarr(dims[0], dims[1]) + 1B
  mask = rot(mask, p_angle, /interp, missing=0.0)
  return, mask
end
