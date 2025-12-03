; docformat = 'rst'

function ucomp_read_config_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_read_config'], $
                           /is_function

  return, 1
end


pro ucomp_read_config_ut__define
  compile_opt strictarr

  define = {ucomp_read_config_ut, inherits UCoMPutTestCase}
end
