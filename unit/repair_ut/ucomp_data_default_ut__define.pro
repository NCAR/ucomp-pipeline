; docformat = 'rst'

function ucomp_data_default_ut::test_basic
  compile_opt strictarr

  restore, filepath('20221101.173226.72.ucomp.1074.l0.sav', root=mg_src_root())
  original_primary_header = primary_header
  original_ext_headers = list()
  foreach h, ext_headers do original_ext_headers->add, h
  
  ucomp_data_default, primary_header, ext_data, ext_header

  assert, array_equal(original_primary_header, primary_header), $
          'primary header not the same'

  for e = 0L, n_elements(ext_headers) - 1L do begin
    assert, array_equal(original_ext_headers[e], ext_headers[e]), $
            'ext %d not the same', e + 1
  endfor
  
  return, 1
end


function ucomp_data_default_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  self->addTestingRoutine, ['ucomp_data_default']
  
  return, 1
end


pro ucomp_data_default_ut__define
  compile_opt strictarr

  define = {ucomp_data_default_ut, inherits UCoMPutTestCase}
end
