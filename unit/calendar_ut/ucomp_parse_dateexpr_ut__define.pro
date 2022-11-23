; docformat = 'rst'

function ucomp_parse_dateexpr_ut::test_range
  compile_opt strictarr

  dates = ucomp_parse_dateexpr('20180101-20180201', count=n_dates)
  assert, n_dates eq 31, 'wrong number of dates: %d', n_dates
  assert, dates[0] eq '20180101' && dates[-1] eq '20180131', $
          'wrong start/end date'

  return, 1
end


function ucomp_parse_dateexpr_ut::test_list
  compile_opt strictarr

  standard = ['20180101', '20180102', '20180103', '20180104', '20180201']
  dates = ucomp_parse_dateexpr('20180101-20180105,20180201', count=n_dates)
  assert, n_dates eq n_elements(standard), 'wrong number of dates: %d', n_dates
  assert, array_equal(dates, standard), 'wrong dates'

  return, 1
end


function ucomp_parse_dateexpr_ut::test_wrong_order
  compile_opt strictarr
  @error_is_pass

  dates = ucomp_parse_dateexpr('20180201-20180101', count=n_dates)

  return, 0
end


function ucomp_parse_dateexpr_ut::test_bad_syntax
  compile_opt strictarr
  @error_is_pass

  dates = ucomp_parse_dateexpr('20180101-20180201-20180301', count=n_dates)

  return, 0
end


function ucomp_parse_dateexpr_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_parse_dateexpr', /is_function

  return, 1
end


pro ucomp_parse_dateexpr_ut__define
  compile_opt strictarr

  define = {ucomp_parse_dateexpr_ut, inherits UCoMPutTestCase}
end
