; docformat = 'rst'

function ucomp_display_image_params_ut::test_basic
  compile_opt strictarr

  result = ucomp_display_image_params(0.0, 10.0, 1.0)
  standard = 'min/max: 0 to 10'
  assert, result eq standard, 'incorrect value'
  
  result = ucomp_display_image_params(0.0, 10.0, 0.7)
  standard = 'min/max: 0!E0.7!N to 10!E0.7!N'
  assert, result eq standard, 'incorrect value'
  
  result = ucomp_display_image_params(0.0, 10.0, 0.7, 0.7)
  standard = 'min/max: 0!E0.7!N to 10!E0.7!N, gamma: 0.7'
  assert, result eq standard, 'incorrect value'

  return, 1
end


function ucomp_display_image_params_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_display_image_params'], $
                           /is_function

  return, 1
end


pro ucomp_display_image_params_ut__define
  compile_opt strictarr

  define = {ucomp_display_image_params_ut, inherits UCoMPutTestCase}
end
