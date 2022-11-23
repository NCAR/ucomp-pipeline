; docformat = 'rst'

function ucomp_check_sci_quality_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_check_sci_quality']


  return, 1
end


pro ucomp_check_sci_quality_ut__define
  compile_opt strictarr

  define = {ucomp_check_sci_quality_ut, inherits MGutTestCase}
end
