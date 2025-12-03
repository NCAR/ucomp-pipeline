; docformat = 'rst'

function ucomp_validate_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_validate']


  return, 1
end


pro ucomp_validate_ut__define
  compile_opt strictarr

  define = {ucomp_validate_ut, inherits UCoMPutTestCase}
end
