; docformat = 'rst'

function ucomp_loadct_ut::test_bw
  compile_opt strictarr

  original_device = !d.name
  set_plot, 'Z'
  tvlct, original_rgb, /get

  ucomp_loadct, 'intensity'
  tvlct, rgb, /get
  standard = rebin(reform(bindgen(256), 256, 1), 256, 3)
  assert, array_equal(rgb, standard), 'incorrect color table'

  tvlct, original_rgb
  set_plot, original_device

  return, 1
end


function ucomp_loadct_ut::test_bw_ncolors
  compile_opt strictarr

  original_device = !d.name
  set_plot, 'Z'
  tvlct, original_rgb, /get

  n_colors = 250
  ucomp_loadct, 'intensity', n_colors=n_colors
  tvlct, rgb, /get

  c = (lindgen(n_colors) * 255) / (n_colors - 1)
  standard = rebin(reform((bindgen(256))[c], n_colors, 1), n_colors, 3)
  assert, array_equal(rgb[0:n_colors - 1, *], standard), 'incorrect color table'

  tvlct, original_rgb
  set_plot, original_device

  return, 1
end


function ucomp_loadct_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_loadct']


  return, 1
end


pro ucomp_loadct_ut__define
  compile_opt strictarr

  define = {ucomp_loadct_ut, inherits UCoMPutTestCase}
end
