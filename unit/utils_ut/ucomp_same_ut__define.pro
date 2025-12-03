; docformat = 'rst'

function ucomp_same_ut::test_arrays
  compile_opt strictarr

  assert, ucomp_same(findgen(10), findgen(10)), 'findgen(10)'
  assert, ~ucomp_same(findgen(10), findgen(11)), 'different length findgens'
  assert, ~ucomp_same(findgen(10), findgen(2, 5)), 'different dim findgens'

  return, 1
end


function ucomp_same_ut::test_scalars
  compile_opt strictarr

  assert, ucomp_same(2, 2), 'long 2'
  assert, ~ucomp_same(2, 3), 'different longs'
  assert, ucomp_same('abc', 'abc'), 'string'
  assert, ~ucomp_same('abc', 'abcd'), 'different strings'

  return, 1
end


function ucomp_same_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_same'], $
                           /is_function

  return, 1
end


pro ucomp_same_ut__define
  compile_opt strictarr

  define = {ucomp_same_ut, inherits UCoMPutTestCase}
end
