; docformat = 'rst'

function ucomp_memory_plot_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_memory_plot']


  return, 1
end


pro ucomp_memory_plot_ut__define
  compile_opt strictarr

  define = {ucomp_memory_plot_ut, inherits UCoMPutTestCase}
end
