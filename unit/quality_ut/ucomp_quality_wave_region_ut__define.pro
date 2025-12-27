; docformat = 'rst'

function ucomp_quality_wave_region_ut::make_primary_header, wave_region
  compile_opt strictarr

  mkhdr, primary_header, 0L, /extend, /image
  ucomp_addpar, primary_header, 'FILTER', wave_region

  return, primary_header
end


function ucomp_quality_wave_region_ut::make_ext_headers, wavelengths
  compile_opt strictarr

  ext_headers = list()

  for k = 0L, n_elements(wavelengths) - 1L do begin
    mkhdr, ext_header, dist(1280, 1024), /extend, /image
    ucomp_addpar, ext_header, 'WAVELNG', wavelengths[k]
    ext_headers->add, ext_header
  endfor

  return, ext_headers
end


function ucomp_quality_wave_region_ut::test_basic
  compile_opt strictarr

  primary_header = self->make_primary_header('1074')
  ext_headers = self->make_ext_headers([1074.4, 1074.7, 1075.9, 1076.1])

  quality = ucomp_quality_wave_region(file, $
                                      primary_header, $
                                      ext_data, $
                                      ext_headers, $
                                      run=run)
  assert, quality eq 0, 'failed on good headers'

  return, 1
end


function ucomp_quality_wave_region_ut::test_fail
  compile_opt strictarr

  primary_header = self->make_primary_header('1074')
  ext_headers = self->make_ext_headers([1074.4, 1074.7, 1075.9, 1079.3])

  quality = ucomp_quality_wave_region(file, $
                                      primary_header, $
                                      ext_data, $
                                      ext_headers, $
                                      run=run)
  assert, quality eq 1, 'passed on bad headers'

  return, 1
end


function ucomp_quality_wave_region_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0

  
  self->addTestingRoutine, ['ucomp_quality_wave_region'], $
                           /is_function

  return, 1
end


pro ucomp_quality_wave_region_ut__define
  compile_opt strictarr

  define = {ucomp_quality_wave_region_ut, inherits UCoMPutTestCase}
end
