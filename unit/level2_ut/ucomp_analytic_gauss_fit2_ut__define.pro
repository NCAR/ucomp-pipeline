; docformat = 'rst'

function ucomp_analytic_gauss_fit2_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_analytic_gauss_fit2'], $
                           /is_function

  return, 1
end


pro ucomp_analytic_gauss_fit2_ut__define
  compile_opt strictarr

  define = {ucomp_analytic_gauss_fit2_ut, inherits MGutTestCase}
end
