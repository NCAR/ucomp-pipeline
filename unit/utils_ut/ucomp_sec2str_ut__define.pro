; docformat = 'rst'

function ucomp_sec2str_ut::test_basic
  compile_opt strictarr

  secs = 3 * 60L * 60L * 24L + 2 * 60 * 60 + 1 * 60 + 2
  assert, ucomp_sec2str(secs) eq '3 days 2 hrs 1 min 2 secs'

  return, 1
end


function ucomp_sec2str_ut::test_nan
  compile_opt strictarr

  assert, ucomp_sec2str(!values.f_nan) eq 'unknown time', 'invalid time'

  return, 1
end


function ucomp_sec2str_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_sec2str', /is_function

  return, 1
end


pro ucomp_sec2str_ut__define
  compile_opt strictarr

  define = {ucomp_sec2str_ut, inherits UCoMPutTestCase}
end
