; docformat = 'rst'

function ucomp_increment_date_ut::test_basic
  compile_opt strictarr

  date = '20131231'
  result = ucomp_increment_date(date)
  assert, result eq '20140101', 'incorrect date: %s', result

  return, 1
end


function ucomp_increment_date_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_increment_date'], $
                           /is_function

  return, 1
end


pro ucomp_increment_date_ut__define
  compile_opt strictarr

  define = {ucomp_increment_date_ut, inherits MGutTestCase}
end
