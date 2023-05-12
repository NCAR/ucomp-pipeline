; docformat = 'rst'

function ucomp_offsensor_mask, dims, p_angle
  compile_opt strictarr

  mask = bytarr(dims[0], dims[1]) + 1B
  mask = rot(mask, p_angle, /interp, missing=0.0)
  return, mask
end
