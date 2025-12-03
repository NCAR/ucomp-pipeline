; docformat = 'rst'

function ucomp_offsensor_mask_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_offsensor_mask'], $
                           /is_function

  return, 1
end


pro ucomp_offsensor_mask_ut__define
  compile_opt strictarr

  define = {ucomp_offsensor_mask_ut, inherits UCoMPutTestCase}
end
