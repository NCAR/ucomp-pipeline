; docformat = 'rst'

function ucomp_idlsave2dateobs_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_idlsave2dateobs'], $
                           /is_function

  return, 1
end


pro ucomp_idlsave2dateobs_ut__define
  compile_opt strictarr

  define = {ucomp_idlsave2dateobs_ut, inherits UCoMPutTestCase}
end
