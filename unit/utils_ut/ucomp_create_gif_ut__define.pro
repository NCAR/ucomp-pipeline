; docformat = 'rst'

function ucomp_create_gif_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_create_gif']


  return, 1
end


pro ucomp_create_gif_ut__define
  compile_opt strictarr

  define = {ucomp_create_gif_ut, inherits UCoMPutTestCase}
end
