; docformat = 'rst'

function ucomp_quality_check_nominal_temps_ut::make_header, temp
  compile_opt strictarr

  mkhdr, primary_header, dist(1280, 1024), /extend, /image

  locations = ['BASE', 'LNB1', 'LNB2', 'RACK']
  std_keywords = ['T_' + locations, $
                  'TU_' + locations, $
                  'TU_C' + ['0', '1'] + 'ARR']
  for k = 0L, n_elements(std_keywords) - 1L do begin
    ucomp_addpar, primary_header, std_keywords[k], temp
  endfor


  lcvr_keywords = 'LCVR' + ['1', '2', '3', '4', '5']
  lcvr_keywords = ['T_' + lcvr_keywords, 'TU_' + lcvr_keywords]

  for k = 0L, n_elements(lcvr_keywords) - 1L do begin
    ucomp_addpar, primary_header, lcvr_keywords[k], temp
  endfor

  mod_keywords = ['T_', 'TU_'] + 'MOD'
  for k = 0L, n_elements(mod_keywords) - 1L do begin
    ucomp_addpar, primary_header, mod_keywords[k], temp
  endfor

  return, primary_header
end


function ucomp_quality_check_nominal_temps_ut::test_basic
  compile_opt strictarr

  primary_header = self->make_header(32.0)

  quality = ucomp_quality_check_nominal_temps(file, $
                                              primary_header, $
                                              ext_data, $
                                              ext_headers, $
                                              run=run)
  assert, quality eq 0, 'valid temps failed'

  ucomp_addpar, primary_header, 'T_LCVR3', 40.0

  quality = ucomp_quality_check_nominal_temps(file, $
                                              primary_header, $
                                              ext_data, $
                                              ext_headers, $
                                              run=run)
  assert, quality eq 1, 'invalid temps passed'

  ucomp_addpar, primary_header, 'T_LCVR3', 29.0

  quality = ucomp_quality_check_nominal_temps(file, $
                                              primary_header, $
                                              ext_data, $
                                              ext_headers, $
                                              run=run)
  assert, quality eq 1, 'invalid temps passed'

  ucomp_addpar, primary_header, 'T_LCVR3', 32.0
  ucomp_addpar, primary_header, 'TU_LNB1', 51.0

  quality = ucomp_quality_check_nominal_temps(file, $
                                              primary_header, $
                                              ext_data, $
                                              ext_headers, $
                                              run=run)
  assert, quality eq 1, 'invalid temps passed'

  return, 1
end


function ucomp_quality_check_nominal_temps_ut::test_nan
  compile_opt strictarr

  primary_header = self->make_header(32.0)

  ucomp_addpar, primary_header, 'T_LCVR3', !values.f_nan

  quality = ucomp_quality_check_nominal_temps(file, $
                                              primary_header, $
                                              ext_data, $
                                              ext_headers, $
                                              run=run)
  assert, quality eq 0, 'valid temps failed'

  ucomp_addpar, primary_header, 'TU_MOD', !values.f_nan

  quality = ucomp_quality_check_nominal_temps(file, $
                                              primary_header, $
                                              ext_data, $
                                              ext_headers, $
                                              run=run)
  assert, quality eq 1, 'invalid temps passed'

  return, 1
end


function ucomp_quality_check_nominal_temps_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_quality_check_nominal_temps'], $
                           /is_function

  return, 1
end


pro ucomp_quality_check_nominal_temps_ut__define
  compile_opt strictarr

  define = {ucomp_quality_check_nominal_temps_ut, inherits UCoMPutTestCase}
end
