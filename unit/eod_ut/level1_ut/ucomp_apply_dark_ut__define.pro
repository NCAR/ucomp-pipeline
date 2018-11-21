; docformat = 'rst'

function ucomp_apply_dark_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_apply_dark'

  return, 1
end


pro ucomp_apply_dark_ut__define
  compile_opt strictarr

  define = { ucomp_apply_dark_ut, inherits UCoMPutTestCase }
end