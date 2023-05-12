; docformat = 'rst'

function ucomp_occulter_mask, dims, occulter_radius
  compile_opt strictarr

  d = shift(dist(dims[0], dims[1]), dims[0] / 2L, dims[1] / 2L)
  return, d gt occulter_radius
end
