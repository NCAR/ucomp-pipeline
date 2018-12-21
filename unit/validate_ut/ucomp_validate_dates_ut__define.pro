; docformat = 'rst'

function ucomp_validate_dates_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_validate_dates']
  self->addTestingRoutine, ['ucomp_validate_dates_expandrange'], /is_function

  return, 1
end


pro ucomp_validate_dates_ut__define
  compile_opt strictarr

  define = {ucomp_validate_dates_ut, inherits UCoMPutTestCase}
end
