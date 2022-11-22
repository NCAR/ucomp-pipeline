; docformat = 'rst'

function ucomp_analytic_gauss_fit_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_analytic_gauss_fit']


  return, 1
end


pro ucomp_analytic_gauss_fit_ut__define
  compile_opt strictarr

  define = {ucomp_analytic_gauss_fit_ut, inherits MGutTestCase}
end
