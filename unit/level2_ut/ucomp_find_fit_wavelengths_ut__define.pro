; docformat = 'rst'

function ucomp_find_fit_wavelengths_ut::test_basic
  compile_opt strictarr

  center_wavelength          = 1074.7
  blue_reference_wavelength  = 1074.59
  red_reference_wavelength   = 1074.81
  wavelengths = [1074.60, 1074.62, 1074.72, 1074.79, 1074.80]

  ucomp_find_fit_wavelengths, blue_reference_wavelength, $
                              center_wavelength, $
                              red_reference_wavelength, $
                              wavelengths, $
                              blue_index=blue_index, $
                              center_index=center_index, $
                              red_index=red_index

  assert, blue_index eq 0, 'incorrect blue index: %d', blue_index
  assert, center_index eq 2, 'incorrect center index: %d', center_index
  assert, red_index eq 4, 'incorrect red index: %d', red_index

  return, 1
end


function ucomp_find_fit_wavelengths_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_find_fit_wavelengths']
  

  return, 1
end


pro ucomp_find_fit_wavelengths_ut__define
  compile_opt strictarr

  define = {ucomp_find_fit_wavelengths_ut, inherits UCoMPutTestCase}
end
