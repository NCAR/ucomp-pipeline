; docformat = 'rst'

function ucomp_fix_permissions_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_fix_permissions']
  

  return, 1
end


pro ucomp_fix_permissions_ut__define
  compile_opt strictarr

  define = {ucomp_fix_permissions_ut, inherits UCoMPutTestCase}
end
