; docformat = 'rst'

function ucomp_verify_dates_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_verify_dates']
  self->addTestingRoutine, ['ucomp_verify_dates_expandrange'], /is_function

  return, 1
end


pro ucomp_verify_dates_ut__define
  compile_opt strictarr

  define = { ucomp_verify_dates_ut, inherits UCoMPutTestCase }
end