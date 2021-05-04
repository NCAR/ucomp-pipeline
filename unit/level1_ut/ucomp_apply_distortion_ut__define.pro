; docformat = 'rst'

function ucomp_apply_distortion_ut::test_identity
  compile_opt strictarr

  x = randomu(seed, 5, 5)
  dx_c = fltarr(3, 3)
  dy_c = fltarr(3, 3)

  new_x = ucomp_apply_distortion(x, dx_c, dy_c)

  assert, array_equal(x, new_x), 'result not identical'

  return, 1
end


function ucomp_apply_distortion_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_apply_distortion'], $
                           /is_function

  return, 1
end


pro ucomp_apply_distortion_ut__define
  compile_opt strictarr

  define = {ucomp_apply_distortion_ut, inherits MGutTestCase}
end
