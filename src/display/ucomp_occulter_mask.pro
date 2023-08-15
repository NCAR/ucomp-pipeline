; docformat = 'rst'

;+
; Create a mask that does not display inside the given radius.
;
; :Returns:
;   mask as a `bytarr(dims)` array
;
; :Params:
;   dims : in, required, type=lonarr(2)
;     dimensions of the mask to produce
;   occulter_radius : in, required, type=float
;     radius in pixels to exclude
;-
function ucomp_occulter_mask, dims, occulter_radius
  compile_opt strictarr

  if (n_elements(occulter_radius) eq 0L || ~finite(occulter_radius)) then begin
    return, bytarr(dims[0], dims[1]) + 1B
  endif
  d = shift(dist(dims[0], dims[1]), dims[0] / 2L, dims[1] / 2L)
  return, d gt occulter_radius
end
