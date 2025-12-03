; docformat = 'rst'

function ucomp_plot_temp_vs_voltage_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_plot_temp_vs_voltage']
  

  return, 1
end


pro ucomp_plot_temp_vs_voltage_ut__define
  compile_opt strictarr

  define = {ucomp_plot_temp_vs_voltage_ut, inherits UCoMPutTestCase}
end
