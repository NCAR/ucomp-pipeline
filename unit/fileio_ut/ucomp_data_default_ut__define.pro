; docformat = 'rst'

function ucomp_data_default_ut::test_basic
  compile_opt strictarr

  ucomp_data_default, primary_header, ext_data, ext_headers

  return, 1
end


function ucomp_data_default_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'ucomp_data_default'

  return, 1
end


pro ucomp_data_default_ut__define
  compile_opt strictarr

  define = { ucomp_data_default_ut, inherits UCoMPutTestCase }
end
