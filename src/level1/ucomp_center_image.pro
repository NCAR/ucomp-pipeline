; docformat = 'rst'

function ucomp_center_image, im, geometry
  compile_opt strictarr

  dims = size(im, /dimensions)

  xshift = (dims[0] - 1.0) / 2.0 - geometry.occulter_center[0]
  yshift = (dims[1] - 1.0) / 2.0 - geometry.occulter_center[1]

  return, ucomp_fshift(im, xshift, yshift, interp=1)
end
