; docformat = 'rst'

function ucomp_sgs_mean_ut::test_basic
  compile_opt strictarr

  m = ucomp_sgs_mean([1.0, 2.0, 3.0])
  assert, abs(m - 2.0) lt 0.0001, 'invalid mean %0.3f', m
  return, 1
end


function ucomp_sgs_mean_ut::test_null
  compile_opt strictarr

  m = ucomp_sgs_mean(!null)
  assert, finite(m) eq 0, 'mean of null not null'

  return, 1
end


function ucomp_sgs_mean_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_sgs_mean'], $
                           /is_function

  return, 1
end


pro ucomp_sgs_mean_ut__define
  compile_opt strictarr

  define = {ucomp_sgs_mean_ut, inherits UCoMPutTestCase}
end
