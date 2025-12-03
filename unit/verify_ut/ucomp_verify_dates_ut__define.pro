; docformat = 'rst'

function ucomp_verify_dates_ut::test_ucomp_verify_dates_expandrange
  compile_opt strictarr

  start_date = '20201217'
  end_date = '20210107'

  dates = ucomp_verify_dates_expandrange(start_date, end_date, count=n_days)

  standard = ['20201217', '20201218', '20201219', '20201220', '20201221', $
              '20201222', '20201223', '20201224', '20201225', '20201226', $
              '20201227', '20201228', '20201229', '20201230', '20201231', $
              '20210101', '20210102', '20210103', '20210104', '20210105', $
              '20210106']
  assert, array_equal(standard, dates), 'incorrect dates'
  assert, n_days eq n_elements(standard), 'incorrect number of days: %d', n_days

  return, 1
end


function ucomp_verify_dates_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_verify_dates']
  self->addTestingRoutine, ['ucomp_verify_dates_expandrange'], $
                           /is_function

  return, 1
end


pro ucomp_verify_dates_ut__define
  compile_opt strictarr

  define = {ucomp_verify_dates_ut, inherits UCoMPutTestCase}
end
