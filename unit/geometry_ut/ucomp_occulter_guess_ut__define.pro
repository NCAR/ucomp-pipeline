; docformat = 'rst'

function ucomp_occulter_guess_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_occulter_guess'], $
                           /is_function

  return, 1
end


pro ucomp_occulter_guess_ut__define
  compile_opt strictarr

  define = {ucomp_occulter_guess_ut, inherits UCoMPutTestCase}
end
