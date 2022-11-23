; docformat = 'rst'

function ucomp_get_dmatrix_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_get_dmatrix'], $
                           /is_function

  return, 1
end


pro ucomp_get_dmatrix_ut__define
  compile_opt strictarr

  define = {ucomp_get_dmatrix_ut, inherits MGutTestCase}
end
