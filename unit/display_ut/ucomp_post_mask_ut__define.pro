; docformat = 'rst'

function ucomp_post_mask_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_post_mask'], $
                           /is_function

  return, 1
end


pro ucomp_post_mask_ut__define
  compile_opt strictarr

  define = {ucomp_post_mask_ut, inherits UCoMPutTestCase}
end
