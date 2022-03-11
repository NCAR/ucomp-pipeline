; docformat = 'rst'

function ucomp_sgs_plots_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_sgs_plots']
  

  return, 1
end


pro ucomp_sgs_plots_ut__define
  compile_opt strictarr

  define = {ucomp_sgs_plots_ut, inherits MGutTestCase}
end
