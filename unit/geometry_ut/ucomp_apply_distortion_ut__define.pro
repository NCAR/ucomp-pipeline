; docformat = 'rst'

function ucomp_apply_distortion_ut::test_identity
  compile_opt strictarr

  nx = 1280L
  ny = 1024L

  im = randomu(seed, nx, ny)
  dx_c = fltarr(3, 3)
  dy_c = fltarr(3, 3)

  x = dindgen(nx, ny) mod nx
  y = transpose(dindgen(ny, nx) mod ny)

  dx_c = x + ucomp_eval_surf(dx_c, dindgen(nx), dindgen(ny))
  dy_c = y + ucomp_eval_surf(dy_c, dindgen(nx), dindgen(ny))

  new_im = ucomp_apply_distortion(im, dx_c, dy_c)

  assert, array_equal(im, new_im), 'result not identical'

  return, 1
end


function ucomp_apply_distortion_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_apply_distortion'], $
                           /is_function

  return, 1
end


pro ucomp_apply_distortion_ut__define
  compile_opt strictarr

  define = {ucomp_apply_distortion_ut, inherits UCoMPutTestCase}
end
