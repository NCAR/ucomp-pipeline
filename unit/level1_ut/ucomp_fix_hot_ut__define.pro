; docformat = 'rst'

function ucomp_fix_hot_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_fix_hot'], $
                           /is_function

  return, 1
end


pro ucomp_fix_hot_ut__define
  compile_opt strictarr

  define = {ucomp_fix_hot_ut, inherits MGutTestCase}
end
