; docformat = 'rst'

function ucomp_wave_type_ut::test_basic
  compile_opt strictarr

  value = 691.4
  result = ucomp_wave_type(value)
  standard = '692'
  assert, result eq standard, 'wrong type for %0.1f', value
  
  return, 1
end


function ucomp_wave_type_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_wave_type', /is_function

  return, 1
end


pro ucomp_wave_type_ut__define
  compile_opt strictarr

  define = { ucomp_wave_type_ut, inherits UCoMPutTestCase }
end