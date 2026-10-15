; docformat = 'rst'

;+
; Produce a mask of the given size.
;
; :Returns:
;   mask as a `bytarr(dims)` array
;
; :Params:
;   dims : in, required, type=lonarr(2)
;     dimensions of the mask to produce
;
; :Keywords:
;   field_radius : in, optional, type=float
;     if present, mask field using this radius, in pixels
;   occulter_radius : in, optional, type=float
;     if present, mask occulter using this radius, in pixels
;   post_angle : in, optional, type=float
;     if present, mask the post using this position angle, in degrees
;   post_width : in, optional, type=float, default=70
;     post width in pixels, can be obtained from a geometry object's
;     `PIXEL_POST_WIDTH` property
;   p_angle : in, optional, type=float
;     if present, mask the pixels that are brought into the frame by the
;     p-angle rotation, in degrees
;   nan : in, optional, type=boolean
;     set to provide a mask that is 1's and NaNs instead of 1's and 0's
;-
function ucomp_mask, dims, $
                     field_radius=field_radius, $
                     occulter_radius=occulter_radius, $
                     post_angle=post_angle, $
                     post_width=post_width, $
                     p_angle=p_angle, $
                     nan=nan
  compile_opt strictarr

  mask = bytarr(dims[0], dims[1]) + 1B

  if (n_elements(field_radius) gt 0L) then begin
    field_mask = ucomp_field_mask(dims, field_radius)
    mask and= field_mask
  endif

  if (n_elements(occulter_radius) gt 0L) then begin
    occulter_mask = ucomp_occulter_mask(dims, occulter_radius)
    mask and= occulter_mask
  endif

  if (n_elements(post_angle) gt 0L) then begin
    post_mask = ucomp_post_mask(dims, post_angle, post_width=post_width)
    mask and= post_mask
  endif

  if (n_elements(p_angle) gt 0L) then begin
    offsensor_mask = ucomp_offsensor_mask(dims, p_angle)
    mask and= offsensor_mask
  endif

  if (keyword_set(nan)) then begin
    mask = float(mask)
    mask[where(mask eq 0, count, /null)] = !values.f_nan
  endif

  return, mask
end
