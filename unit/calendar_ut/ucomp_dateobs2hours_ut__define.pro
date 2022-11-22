; docformat = 'rst'

function ucomp_dateobs2hours_ut::test_basic
  compile_opt strictarr

  dateobs = '2021-01-01 10:00:00'
  hours = ucomp_dateobs2hours(dateobs)
  assert, hours eq 0.0, 'incorrect hours'

  return, 1
end


function ucomp_dateobs2hours_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_dateobs2hours'], $
                           /is_function

  return, 1
end


pro ucomp_dateobs2hours_ut__define
  compile_opt strictarr

  define = {ucomp_dateobs2hours_ut, inherits MGutTestCase}
end
