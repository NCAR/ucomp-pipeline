; docformat = 'rst'

function ucomp_ut2hst_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_ut2hst']
  

  return, 1
end


pro ucomp_ut2hst_ut__define
  compile_opt strictarr

  define = {ucomp_ut2hst_ut, inherits MGutTestCase}
end
