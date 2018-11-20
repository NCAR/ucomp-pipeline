; docformat = 'rst'

function ucomp_verify_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_verify', 'ucomp_verify_hpss']

  return, 1
end


pro ucomp_verify_ut__define
  compile_opt strictarr

  define = { ucomp_verify_ut, inherits UCoMPutTestCase }
end