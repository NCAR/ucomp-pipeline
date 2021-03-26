; docformat = 'rst'

function ucomp_rotate_north_up_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_rotate_north_up']
  

  return, 1
end


pro ucomp_rotate_north_up_ut__define
  compile_opt strictarr

  define = {ucomp_rotate_north_up_ut, inherits MGutTestCase}
end
