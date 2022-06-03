; docformat = 'rst'

function ucomp_offsensor_mask, nx, ny, p_angle
  compile_opt strictarr

  mask = bytarr(nx, ny) + 1B
  mask = rot(mask, p_angle, /interp, missing=0.0)
  return, mask
end
