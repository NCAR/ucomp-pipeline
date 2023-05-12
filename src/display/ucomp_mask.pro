; docformat = 'rst'

function ucomp_mask, dims, $
                     field_radius=field_radius, $
                     occulter_radius=occulter_radius, $
                     post_angle=post_angle, $
                     p_angle=p_angle
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
    post_mask = ucomp_post_mask(dims, post_angle)
    mask and= post_mask
  endif

  if (n_elements(p_angle) gt 0L) then begin
    offsensor_mask = ucomp_offsensor_mask(dims, p_angle)
    mask and= offsensor_mask
  endif

  return, mask
end
