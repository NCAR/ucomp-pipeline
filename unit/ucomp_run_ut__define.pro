; docformat = 'rst'

function ucomp_run_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_run__define'

  return, 1
end


pro ucomp_run_ut__define
  compile_opt strictarr

  define = { ucomp_run_ut, inherits UCoMPutTestCase }
end