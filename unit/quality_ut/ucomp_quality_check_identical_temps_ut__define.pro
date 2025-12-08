; docformat = 'rst'


function ucomp_quality_check_identical_temps_ut::make_header, temp
  compile_opt strictarr

  mkhdr, primary_header, dist(1280, 1024), /extend, /image

  lcvr_keywords = 'LCVR' + ['1', '2', '3', '4', '5']
  for k = 0L, n_elements(lcvr_keywords) - 1L do begin
    ucomp_addpar, primary_header, 'T_' + lcvr_keywords[k], temp
    ucomp_addpar, primary_header, 'TU_' + lcvr_keywords[k], temp
  endfor

  locations = ['BASE', 'LNB1', 'MOD', 'LNB2', 'RACK']
  all_temp_keywords = ['T_' + locations, $
                       'TU_' + locations, $
                       'T_' + lcvr_keywords, $
                       'TU_' + lcvr_keywords, $
                       'TU_C0' + ['ARR', 'PCB'], $
                       'TU_C1' + ['ARR', 'PCB']]

  for k = 0L, n_elements(all_temp_keywords) - 1L do begin
    ucomp_addpar, primary_header, all_temp_keywords[k], temp
  endfor

  return, primary_header
end


function ucomp_quality_check_identical_temps_ut::test_basic
  compile_opt strictarr

  temp = 34.0
  primary_header = self->make_header(temp)

  quality = ucomp_quality_check_identical_temps(file, $
                                                primary_header, $
                                                ext_data, $
                                                ext_headers, $
                                                backgrounds, $
                                                run=run)
  assert, quality eq 1, 'identical temps passed'

  ucomp_addpar, primary_header, 'T_LCVR3', temp + 0.001
  ucomp_addpar, primary_header, 'TU_LCVR1', temp + 0.001
  ucomp_addpar, primary_header, 'T_BASE', temp + 0.001

  quality = ucomp_quality_check_identical_temps(file, $
                                                primary_header, $
                                                ext_data, $
                                                ext_headers, $
                                                backgrounds, $
                                                run=run)
  assert, quality eq 0, 'non-identical temps failed'

  return, 1
end


function ucomp_quality_check_identical_temps_ut::test_nan
  compile_opt strictarr

  temp = 34.0
  primary_header = self->make_header(temp)

  ucomp_addpar, primary_header, 'T_LCVR3', !values.f_nan
  ucomp_addpar, primary_header, 'TU_LCVR1', !values.f_nan
  ucomp_addpar, primary_header, 'T_BASE', !values.f_nan

  quality = ucomp_quality_check_identical_temps(file, $
                                                primary_header, $
                                                ext_data, $
                                                ext_headers, $
                                                backgrounds, $
                                                run=run)
  assert, quality eq 1, 'identical temps passed'

  ucomp_addpar, primary_header, 'T_LCVR4', temp + 0.001
  ucomp_addpar, primary_header, 'TU_LCVR2', temp + 0.001
  ucomp_addpar, primary_header, 'T_MOD', temp + 0.001

  quality = ucomp_quality_check_identical_temps(file, $
                                                primary_header, $
                                                ext_data, $
                                                ext_headers, $
                                                backgrounds, $
                                                run=run)
  assert, quality eq 0, 'non-identical temps failed'

  return, 1
end


function ucomp_quality_check_identical_temps_ut::init, _extra=e
  compile_opt strictarr

  if (~self->UCoMPutTestCase::init(_extra=e)) then return, 0


  self->addTestingRoutine, ['ucomp_quality_check_identical_temps'], $
                           /is_function

  return, 1
end


pro ucomp_quality_check_identical_temps_ut__define
  compile_opt strictarr

  define = {ucomp_quality_check_identical_temps_ut, inherits UCoMPutTestCase}
end
