; docformat = 'rst'

function ucomp_hst2ut_ut::test_basic
  compile_opt strictarr

  ucomp_hst2ut, '20180101', '072314', ut_date=ut_date, ut_time=ut_time
  assert, ut_date eq '20180101', 'wrong date: %s', ut_date
  assert, ut_time eq '172314', 'wrong time: %s', ut_time

  return, 1
end


function ucomp_hst2ut_ut::test_roundup
  compile_opt strictarr

  ; Rounding up never seems to happen because CALDAT adds 1e-12 days, i.e.,
  ; about 8.6e-8 seconds, so the rounding is always down. Then we never get
  ; something like 59.999 seconds that needs to be rounded up, so the special
  ; case for this in UCOMP_HST2UT is never called.

  ucomp_hst2ut, '20150702', '090000', ut_date=ut_date, ut_time=ut_time
  assert, ut_date eq '20150702', 'wrong date: %s', ut_date
  assert, ut_time eq '190000', 'wrong time: %s', ut_time

  return, 1
end


function ucomp_hst2ut_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_hst2ut'

  return, 1
end


pro ucomp_hst2ut_ut__define
  compile_opt strictarr

  define = { ucomp_hst2ut_ut, inherits UCoMPutTestCase }
end
