; docformat = 'rst'

function ucomp_occulter_mask, nx, ny, occulter_radius
  compile_opt strictarr

  d = shift(dist(nx, ny), nx / 2L, ny / 2L)
  return, d gt occulter_radius
end
