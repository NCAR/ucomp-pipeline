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


function ucomp_find_fit_wavelengths_ut::test_between1
  compile_opt strictarr

  center_wavelength = 637.4
  blue_reference_wavelength = 637.350
  red_reference_wavelength = 637.450
  wavelengths = [637.340, 637.360, 637.380, 637.390, $
                 637.400, $
                 637.410, 637.420, 637.440, 637.460]

  ucomp_find_fit_wavelengths, blue_reference_wavelength, $
                              center_wavelength, $
                              red_reference_wavelength, $
                              wavelengths, $
                              blue_index=blue_index, $
                              center_index=center_index, $
                              red_index=red_index

  assert, blue_index eq 0, 'incorrect blue index: %d', blue_index
  assert, center_index eq 4, 'incorrect center index: %d', center_index
  assert, red_index eq 8, 'incorrect red index: %d', red_index

  return, 1
end


function ucomp_find_fit_wavelengths_ut::test_between2
  compile_opt strictarr

  center_wavelength = 1074.700
  blue_reference_wavelength = 1074.590
  red_reference_wavelength = 1074.810
  wavelengths = [1074.580, 1074.600, 1074.620, 1074.640, 1074.660, 1074.680, $
                 1074.700, $
                 1074.720, 1074.740, 1074.760, 1074.780, 1074.800, 1074.820]

  ucomp_find_fit_wavelengths, blue_reference_wavelength, $
                              center_wavelength, $
                              red_reference_wavelength, $
                              wavelengths, $
                              blue_index=blue_index, $
                              center_index=center_index, $
                              red_index=red_index

  assert, blue_index eq 0, 'incorrect blue index: %d', blue_index
  assert, center_index eq 6, 'incorrect center index: %d', center_index
  assert, red_index eq 12, 'incorrect red index: %d', red_index

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
