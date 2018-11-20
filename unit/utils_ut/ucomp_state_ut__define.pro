; docformat = 'rst'

function ucomp_state_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_state', /is_function

  return, 1
end


pro ucomp_state_ut__define
  compile_opt strictarr

  define = { ucomp_state_ut, inherits UCoMPutTestCase }
end