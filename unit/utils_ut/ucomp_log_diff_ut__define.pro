; docformat = 'rst'

function ucomp_log_diff_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_log_diff', 'ucomp_log_diff_read'], $
                           /is_function

  return, 1
end


pro ucomp_log_diff_ut__define
  compile_opt strictarr

  define = { ucomp_log_diff_ut, inherits UCoMPutTestCase }
end
