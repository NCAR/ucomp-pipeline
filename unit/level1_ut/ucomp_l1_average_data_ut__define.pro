; docformat = 'rst'

function ucomp_l1_average_data_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_l1_average_data']


  return, 1
end


pro ucomp_l1_average_data_ut__define
  compile_opt strictarr

  define = {ucomp_l1_average_data_ut, inherits MGutTestCase}
end
