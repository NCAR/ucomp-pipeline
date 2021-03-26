; docformat = 'rst'

function ucomp_mkdir_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_mkdir']
  

  return, 1
end


pro ucomp_mkdir_ut__define
  compile_opt strictarr

  define = {ucomp_mkdir_ut, inherits MGutTestCase}
end
