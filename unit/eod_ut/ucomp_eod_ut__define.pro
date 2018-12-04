; docformat = 'rst'

function ucomp_eod_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_eod'

  return, 1
end


pro ucomp_eod_ut__define
  compile_opt strictarr

  define = {ucomp_eod_ut, inherits UCoMPutTestCase}
end
