; docformat = 'rst'

function ucomp_quality_contin_ut::make_ext_headers, contins
  compile_opt strictarr

  ext_headers = list()

  for k = 0L, n_elements(contins) - 1L do begin
    mkhdr, ext_header, dist(1280, 1024), /extend, /image
    ucomp_addpar, ext_header, 'CONTIN', boolean(contins[k])
    ext_headers->add, ext_header
  endfor

  return, ext_headers
end


function ucomp_quality_contin_ut::test_basic
  compile_opt strictarr

  ext_headers = self->make_ext_headers([0B, 0B, 0B, 0B, 0B])

  quality = ucomp_quality_contin(file, $
                                 primary_header, $
                                 ext_data, $
                                 ext_headers, $
                                 run=run)

  assert, quality eq 0, 'failed on good headers'

  obj_destroy, ext_headers
  return, 1
end


function ucomp_quality_contin_ut::test_fail
  compile_opt strictarr

  run = self->get_run()
  ext_headers = self->make_ext_headers([0B, 1B, 0B, 0B, 0B])

  quality = ucomp_quality_contin(file, $
                                 primary_header, $
                                 ext_data, $
                                 ext_headers, $
                                 run=run)

  assert, quality eq 1, 'succeeded on bad headers'

  obj_destroy, [ext_headers, run]
  return, 1
end


function ucomp_quality_contin_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_quality_contin'], $
                           /is_function

  return, 1
end


pro ucomp_quality_contin_ut__define
  compile_opt strictarr

  define = {ucomp_quality_contin_ut, inherits UCoMPutTestCase}
end
