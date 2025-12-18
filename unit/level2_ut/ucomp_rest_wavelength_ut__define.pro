; docformat = 'rst'

function ucomp_rest_wavelength_ut::test_basic
  compile_opt strictarr

  coeffs = [1100.069946, -2.048975, 0.040610]
  date = '20221101'
  standard = 1074.4570
  tolerance = 0.001

  result = ucomp_rest_wavelength(date, coeffs)

  assert, abs(result - standard) lt tolerance, $
          'rest wavelength %0.3f incorrect', result

  return, 1
end


function ucomp_rest_wavelength_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_rest_wavelength'], $
                           /is_function

  return, 1
end


pro ucomp_rest_wavelength_ut__define
  compile_opt strictarr

  define = {ucomp_rest_wavelength_ut, inherits UCoMPutTestCase}
end
