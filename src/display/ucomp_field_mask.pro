; docformat = 'rst'

function ucomp_field_mask, dims, field_radius
  compile_opt strictarr

  d = shift(dist(dims[0], dims[1]), dims[0] / 2L, dims[1] / 2L)
  return, d lt field_radius
end
