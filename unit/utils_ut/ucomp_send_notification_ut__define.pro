; docformat = 'rst'

function ucomp_send_notification_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_send_notification'

  return, 1
end


pro ucomp_send_notification_ut__define
  compile_opt strictarr

  define = { ucomp_send_notification_ut, inherits UCoMPutTestCase }
end
