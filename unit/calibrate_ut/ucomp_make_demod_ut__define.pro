; docformat = 'rst'

function ucomp_make_demod_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_make_demod']


  return, 1
end


pro ucomp_make_demod_ut__define
  compile_opt strictarr

  define = {ucomp_make_demod_ut, inherits UCoMPutTestCase}
end
