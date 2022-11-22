; docformat = 'rst'

function ucomp_l2_polarization_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_l2_polarization']


  return, 1
end


pro ucomp_l2_polarization_ut__define
  compile_opt strictarr

  define = {ucomp_l2_polarization_ut, inherits MGutTestCase}
end
