; docformat = 'rst'

;+
; Create a mask that does not display outside the given radius.
;
; :Returns:
;   mask as a `bytarr(dims)` array
;
; :Params:
;   dims : in, required, type=lonarr(2)
;     dimensions of the mask to produce
;   field_radius : in, required, type=float
;     radius in pixels to exclude
;-
function ucomp_field_mask, dims, field_radius
  compile_opt strictarr

  d = shift(dist(dims[0], dims[1]), dims[0] / 2L, dims[1] / 2L)
  return, d lt field_radius
end
