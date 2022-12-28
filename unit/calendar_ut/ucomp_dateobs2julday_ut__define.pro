; docformat = 'rst'

function ucomp_dateobs2julday_ut::test_basic
  compile_opt strictarr

  dt =  '2020-05-09T00:45:03.04'
  jd = ucomp_dateobs2julday(dt)
  assert, abs(jd - 2458978.5312847229652107d) lt 1.0e-8, 'invalid Julian date: %f', jd
  return, 1
end


function ucomp_dateobs2julday_ut::init, _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_dateobs2julday'], $
                           /is_function

  return, 1
end


pro ucomp_dateobs2julday_ut__define
  compile_opt strictarr

  define = {ucomp_dateobs2julday_ut, inherits MGutTestCase}
end
