; docformat = 'rst'

function ucomp_transmission_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_transmission'], $
                           /is_function

  return, 1
end


pro ucomp_transmission_ut__define
  compile_opt strictarr

  define = {ucomp_transmission_ut, inherits MGutTestCase}
end
