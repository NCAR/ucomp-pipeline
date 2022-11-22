; docformat = 'rst'

function ucomp_apply_linearity_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_apply_linearity'], $
                           /is_function

  return, 1
end


pro ucomp_apply_linearity_ut__define
  compile_opt strictarr

  define = {ucomp_apply_linearity_ut, inherits MGutTestCase}
end
