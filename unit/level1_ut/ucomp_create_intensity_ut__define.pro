; docformat = 'rst'

function ucomp_create_intensity_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_create_intensity']
  

  return, 1
end


pro ucomp_create_intensity_ut__define
  compile_opt strictarr

  define = {ucomp_create_intensity_ut, inherits MGutTestCase}
end
