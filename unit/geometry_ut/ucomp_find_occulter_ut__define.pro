; docformat = 'rst'

function ucomp_find_occulter_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_find_occulter'], $
                           /is_function

  return, 1
end


pro ucomp_find_occulter_ut__define
  compile_opt strictarr

  define = {ucomp_find_occulter_ut, inherits UCoMPutTestCase}
end
