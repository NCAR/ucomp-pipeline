; docformat = 'rst'

function ucomp_db_float_ut::test_empty
  compile_opt strictarr

  result = ucomp_db_float()
  assert, result eq 'NULL', 'incorrect value'
  return, 1
end


function ucomp_db_float_ut::test_nan
  compile_opt strictarr

  result = ucomp_db_float(!values.f_nan)
  assert, result eq 'NULL', 'incorrect value'
  return, 1
end


function ucomp_db_float_ut::test_empty
  compile_opt strictarr

  result = ucomp_db_float(!values.f_infinity)
  assert, result eq 'NULL', 'incorrect value'
  return, 1
end


function ucomp_db_float_ut::test_basic
  compile_opt strictarr

  result = ucomp_db_float(0.0)
  assert, result eq '0.000000', 'incorrect value'
  return, 1
end


function ucomp_db_float_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_db_float'], $
                           /is_function

  return, 1
end


pro ucomp_db_float_ut__define
  compile_opt strictarr

  define = {ucomp_db_float_ut, inherits UCoMPutTestCase}
end
