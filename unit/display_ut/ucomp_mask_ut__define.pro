; docformat = 'rst'

function ucomp_mask_ut::test_basic
  compile_opt strictarr

  dims = [1280, 1024]
  field_radius = 700.0
  occulter_radius = 336.159
  post_angle = 206.838
  p_angle = -25.751

  mask = ucomp_mask(dims, $
                    field_radius=field_radius, $
                    occulter_radius=occulter_radius, $
                    post_angle=post_angle, $
                    p_angle=p_angle)

  assert, array_equal(dims, size(mask, /dimensions)), 'wrong dimensions'

  ; occulter
  assert, mask[640, 175] eq 1, '[640, 175] incorrect'
  assert, mask[640, 176] eq 0, '[640, 176] incorrect'

  ; post
  assert, mask[790, 150] eq 1, '[790, 150] incorrect'
  assert, mask[791, 150] eq 0, '[791, 150] incorrect'

  ; off-sensor
  assert, mask[150, 844] eq 1, '[150, 844] incorrect'
  assert, mask[150, 845] eq 0, '[150, 845] incorrect'

  return, 1
end


function ucomp_mask_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_mask'], $
                           /is_function

  return, 1
end


pro ucomp_mask_ut__define
  compile_opt strictarr

  define = {ucomp_mask_ut, inherits UCoMPutTestCase}
end
