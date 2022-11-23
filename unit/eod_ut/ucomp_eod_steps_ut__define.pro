; docformat = 'rst'

function ucomp_eod_steps_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_eod_steps']


  return, 1
end


pro ucomp_eod_steps_ut__define
  compile_opt strictarr

  define = {ucomp_eod_steps_ut, inherits MGutTestCase}
end
