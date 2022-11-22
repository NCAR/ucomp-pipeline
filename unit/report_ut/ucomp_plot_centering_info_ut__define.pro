; docformat = 'rst'

function ucomp_plot_centering_info_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_plot_centering_info']


  return, 1
end


pro ucomp_plot_centering_info_ut__define
  compile_opt strictarr

  define = {ucomp_plot_centering_info_ut, inherits MGutTestCase}
end
