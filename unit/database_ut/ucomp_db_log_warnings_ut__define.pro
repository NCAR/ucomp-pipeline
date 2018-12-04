; docformat = 'rst'

function ucomp_db_log_warnings_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_db_log_warnings']
  

  return, 1
end


pro ucomp_db_log_warnings_ut__define
  compile_opt strictarr

  define = {ucomp_db_log_warnings_ut, inherits UCoMPutTestCase}
end
