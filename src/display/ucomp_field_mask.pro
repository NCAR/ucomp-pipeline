; docformat = 'rst'

function ucomp_field_mask, nx, ny, field_radius
  compile_opt strictarr

  d = shift(dist(nx, ny), nx / 2L, ny / 2L)
  return, d lt field_radius
end

