; docformat = 'rst'

function ucomp_julday2dateobs_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_julday2dateobs'], $
                           /is_function

  return, 1
end


pro ucomp_julday2dateobs_ut__define
  compile_opt strictarr

  define = {ucomp_julday2dateobs_ut, inherits UCoMPutTestCase}
end
