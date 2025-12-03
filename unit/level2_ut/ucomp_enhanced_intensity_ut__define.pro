; docformat = 'rst'

function ucomp_enhanced_intensity_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_enhanced_intensity'], $
                           /is_function

  return, 1
end


pro ucomp_enhanced_intensity_ut__define
  compile_opt strictarr

  define = {ucomp_enhanced_intensity_ut, inherits UCoMPutTestCase}
end
