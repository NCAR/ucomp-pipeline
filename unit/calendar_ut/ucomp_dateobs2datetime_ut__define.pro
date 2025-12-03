; docformat = 'rst'

function ucomp_dateobs2datetime_ut::test_basic
  compile_opt strictarr

  assert, ucomp_dateobs2datetime('2020-05-09T00:45:03.04') eq '20200509.004503'
  assert, ucomp_dateobs2datetime('2020-05-09T00:45:03Z') eq '20200509.004503'

  return, 1
end


function ucomp_dateobs2datetime_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_dateobs2datetime'], $
                           /is_function

  return, 1
end


pro ucomp_dateobs2datetime_ut__define
  compile_opt strictarr

  define = {ucomp_dateobs2datetime_ut, inherits UCoMPutTestCase}
end
