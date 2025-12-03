; docformat = 'rst'

function ucomp_quality_all_zero_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_quality_all_zero'], $
                           /is_function

  return, 1
end


pro ucomp_quality_all_zero_ut__define
  compile_opt strictarr

  define = {ucomp_quality_all_zero_ut, inherits UCoMPutTestCase}
end
