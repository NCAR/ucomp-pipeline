; docformat = 'rst'

function ucomp_decompose_date_ut::test1
  compile_opt strictarr

  assert, array_equal(ucomp_decompose_date('20180105'), [2018, 1, 5])

  return, 1
end


function ucomp_decompose_date_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_decompose_date', /is_function

  return, 1
end


pro ucomp_decompose_date_ut__define
  compile_opt strictarr

  define = { ucomp_decompose_date_ut, inherits UCoMPutTestCase }
end
