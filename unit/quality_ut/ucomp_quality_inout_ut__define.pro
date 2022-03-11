; docformat = 'rst'

function ucomp_quality_inout_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_quality_inout'], $
                           /is_function

  return, 1
end


pro ucomp_quality_inout_ut__define
  compile_opt strictarr

  define = {ucomp_quality_inout_ut, inherits MGutTestCase}
end
