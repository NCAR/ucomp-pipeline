; docformat = 'rst'

function ucomp_calibration_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_calibration__define', $
                            'ucomp_calibration::cleanup', $
                            'ucomp_calibration::discard_flats', $
                            'ucomp_calibration::cache_flats', $
                            'ucomp_calibration::discard_darks', $
                            'ucomp_calibration::cache_darks']
  self->addTestingRoutine, ['ucomp_calibration::init', $
                            'ucomp_calibration::get_flat', $
                            'ucomp_calibration::get_dark'], $
                           /is_function

  return, 1
end


pro ucomp_calibration_ut__define
  compile_opt strictarr

  define = {ucomp_calibration_ut, inherits MGutTestCase}
end
