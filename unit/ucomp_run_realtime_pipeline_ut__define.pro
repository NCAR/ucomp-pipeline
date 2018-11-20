; docformat = 'rst'

function ucomp_run_realtime_pipeline_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_run_realtime_pipeline'

  return, 1
end


pro ucomp_run_realtime_pipeline_ut__define
  compile_opt strictarr

  define = { ucomp_run_realtime_pipeline_ut, inherits UCoMPutTestCase }
end