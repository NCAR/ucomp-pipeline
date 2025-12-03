; docformat = 'rst'

function ucomp_log_centering_info_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_log_centering_info']


  return, 1
end


pro ucomp_log_centering_info_ut__define
  compile_opt strictarr

  define = {ucomp_log_centering_info_ut, inherits UCoMPutTestCase}
end
