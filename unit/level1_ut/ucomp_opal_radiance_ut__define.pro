; docformat = 'rst'

function ucomp_opal_radiance_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_opal_radiance'], $
                           /is_function

  return, 1
end


pro ucomp_opal_radiance_ut__define
  compile_opt strictarr

  define = {ucomp_opal_radiance_ut, inherits UCoMPutTestCase}
end
