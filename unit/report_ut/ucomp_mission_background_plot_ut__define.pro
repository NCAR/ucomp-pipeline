; docformat = 'rst'

function ucomp_mission_background_plot_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_mission_background_plot']
  

  return, 1
end


pro ucomp_mission_background_plot_ut__define
  compile_opt strictarr

  define = {ucomp_mission_background_plot_ut, inherits MGutTestCase}
end
