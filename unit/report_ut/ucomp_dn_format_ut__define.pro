; docformat = 'rst'

function ucomp_dn_format_ut::test_basic
  compile_opt strictarr

  value = 123456.7
  result = mg_float2str(long(value), places_sep=',')
  standard = '123,456'
  assert, result eq standard, 'incorrect formatted value: %s', result

  return, 1
end


function ucomp_dn_format_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_dn_format'], $
                           /is_function

  return, 1
end


pro ucomp_dn_format_ut__define
  compile_opt strictarr

  define = {ucomp_dn_format_ut, inherits UCoMPutTestCase}
end
