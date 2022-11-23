; docformat = 'rst'

function comp_compute_average_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['comp_compute_average']


  return, 1
end


pro comp_compute_average_ut__define
  compile_opt strictarr

  define = {comp_compute_average_ut, inherits MGutTestCase}
end
