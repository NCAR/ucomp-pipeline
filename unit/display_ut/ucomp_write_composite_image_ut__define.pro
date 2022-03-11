; docformat = 'rst'

function ucomp_write_composite_image_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_write_composite_image']
  self->addTestingRoutine, ['ucomp_write_composite_image_channel'], $
                           /is_function

  return, 1
end


pro ucomp_write_composite_image_ut__define
  compile_opt strictarr

  define = {ucomp_write_composite_image_ut, inherits MGutTestCase}
end
