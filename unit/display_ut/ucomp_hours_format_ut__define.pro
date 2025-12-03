; docformat = 'rst'

function ucomp_hours_format_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_hours_format'], $
                           /is_function

  return, 1
end


pro ucomp_hours_format_ut__define
  compile_opt strictarr

  define = {ucomp_hours_format_ut, inherits UCoMPutTestCase}
end
