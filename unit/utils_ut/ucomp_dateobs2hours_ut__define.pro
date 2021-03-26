; docformat = 'rst'

function ucomp_dateobs2hours_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_dateobs2hours'], $
                           /is_function

  return, 1
end


pro ucomp_dateobs2hours_ut__define
  compile_opt strictarr

  define = {ucomp_dateobs2hours_ut, inherits MGutTestCase}
end
