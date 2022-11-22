; docformat = 'rst'

function ucomp_pipeline_step_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_pipeline_step'

  return, 1
end


pro ucomp_pipeline_step_ut__define
  compile_opt strictarr

  define = { ucomp_pipeline_step_ut, inherits UCoMPutTestCase }
end
