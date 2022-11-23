; docformat = 'rst'

function ucomp_field_mask_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_field_mask'], $
                           /is_function

  return, 1
end


pro ucomp_field_mask_ut__define
  compile_opt strictarr

  define = {ucomp_field_mask_ut, inherits MGutTestCase}
end
