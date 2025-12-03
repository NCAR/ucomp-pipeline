; docformat = 'rst'

function ucomp_radius_guess_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_radius_guess'], $
                           /is_function

  return, 1
end


pro ucomp_radius_guess_ut__define
  compile_opt strictarr

  define = {ucomp_radius_guess_ut, inherits UCoMPutTestCase}
end
