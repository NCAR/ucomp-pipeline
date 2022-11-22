; docformat = 'rst'

function ucomp_clearday_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_clearday']


  return, 1
end


pro ucomp_clearday_ut__define
  compile_opt strictarr

  define = {ucomp_clearday_ut, inherits UCoMPutTestCase}
end
