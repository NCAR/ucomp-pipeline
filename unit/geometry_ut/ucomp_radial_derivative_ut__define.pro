; docformat = 'rst'

function ucomp_radial_derivative_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_radial_derivative'], $
                           /is_function

  return, 1
end


pro ucomp_radial_derivative_ut__define
  compile_opt strictarr

  define = {ucomp_radial_derivative_ut, inherits MGutTestCase}
end
