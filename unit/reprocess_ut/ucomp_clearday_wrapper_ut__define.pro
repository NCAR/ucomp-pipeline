; docformat = 'rst'

function ucomp_clearday_wrapper_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_clearday_wrapper']


  return, 1
end


pro ucomp_clearday_wrapper_ut__define
  compile_opt strictarr

  define = {ucomp_clearday_wrapper_ut, inherits MGutTestCase}
end
