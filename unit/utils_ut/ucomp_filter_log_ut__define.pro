; docformat = 'rst'

function ucomp_filter_log_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_filter_log'], $
                           /is_function

  return, 1
end


pro ucomp_filter_log_ut__define
  compile_opt strictarr

  define = {ucomp_filter_log_ut, inherits UCoMPutTestCase}
end
