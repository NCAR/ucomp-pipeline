; docformat = 'rst'

function ucomp_daily_o1focus_plot_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_daily_o1focus_plot']
  

  return, 1
end


pro ucomp_daily_o1focus_plot_ut__define
  compile_opt strictarr

  define = {ucomp_daily_o1focus_plot_ut, inherits MGutTestCase}
end
