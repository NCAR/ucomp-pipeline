; docformat = 'rst'

function ucomp_stray_light_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_stray_light'

  return, 1
end


pro ucomp_stray_light_ut__define
  compile_opt strictarr

  define = { ucomp_stray_light_ut, inherits UCoMPutTestCase }
end