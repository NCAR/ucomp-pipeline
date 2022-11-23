; docformat = 'rst'

function ucomp_write_gbu_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_write_gbu']


  return, 1
end


pro ucomp_write_gbu_ut__define
  compile_opt strictarr

  define = {ucomp_write_gbu_ut, inherits MGutTestCase}
end
