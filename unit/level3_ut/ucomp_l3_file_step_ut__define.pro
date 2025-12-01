; docformat = 'rst'

function ucomp_l3_file_step_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_l3_file_step']
  

  return, 1
end


pro ucomp_l3_file_step_ut__define
  compile_opt strictarr

  define = {ucomp_l3_file_step_ut, inherits MGutTestCase}
end
