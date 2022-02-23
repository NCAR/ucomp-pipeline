; docformat = 'rst'

function ucomp_post_mask, nx, ny, post_angle, width=width
  compile_opt strictarr

  return, bytarr(nx, ny) + 1B
end
