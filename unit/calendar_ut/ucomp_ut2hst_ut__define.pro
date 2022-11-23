; docformat = 'rst'

function ucomp_ut2hst_ut::test_basic
  compile_opt strictarr

  ucomp_ut2hst, '20180101', '172314', hst_date=hst_date, hst_time=hst_time, hst_hours=hst_hours
  assert, hst_date eq '20180101', 'wrong date: %s', ut_date
  assert, hst_time eq '072314', 'wrong time: %s', ut_time
  assert, hst_hours eq 7.0 + (23.0 + 14.0 / 60.0) / 60.0, 'incorrect hours: %f', hst_hours

  return, 1
end


function ucomp_ut2hst_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_ut2hst']


  return, 1
end


pro ucomp_ut2hst_ut__define
  compile_opt strictarr

  define = {ucomp_ut2hst_ut, inherits MGutTestCase}
end
