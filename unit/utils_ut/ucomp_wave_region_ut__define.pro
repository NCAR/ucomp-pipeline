; docformat = 'rst'

function ucomp_wave_region_ut::test_basic
  compile_opt strictarr

  value = 691.4
  result = ucomp_wave_region(value)
  standard = '691'
  assert, result eq standard, 'wrong type for %0.1f', value

  return, 1
end


function ucomp_wave_region_ut::test_center
  compile_opt strictarr

  value = 691.4
  result = ucomp_wave_region(value, /central_wavelength)
  standard = 691.8
  tolerance = 0.001
  assert, abs(result - standard) lt tolerance, 'wrong center wavelength for %0.1f', value

  return, 1
end


function ucomp_wave_region_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_wave_region', /is_function

  return, 1
end


pro ucomp_wave_region_ut__define
  compile_opt strictarr

  define = { ucomp_wave_region_ut, inherits UCoMPutTestCase }
end
