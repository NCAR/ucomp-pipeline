; docformat = 'rst'

function ucomp_vcrosstalk_metric_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_vcrosstalk_metric'], $
                           /is_function

  return, 1
end


pro ucomp_vcrosstalk_metric_ut__define
  compile_opt strictarr

  define = {ucomp_vcrosstalk_metric_ut, inherits MGutTestCase}
end
