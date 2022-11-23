; docformat = 'rst'

function ucomp_expfit_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_expfit'], $
                           /is_function

  return, 1
end


pro ucomp_expfit_ut__define
  compile_opt strictarr

  define = {ucomp_expfit_ut, inherits MGutTestCase}
end
