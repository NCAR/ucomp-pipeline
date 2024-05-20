; main-level example program

date = '20220901'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)
db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

wave_regions = ['530', '637', '706', '789', '1074', '1079']
for w = 0L, n_elements(wave_regions) - 1L do begin
  ucomp_rolling_synoptic_map, wave_regions[w], 'intensity', 'int', 'intensity', $
                              1.08, 'r108i', db, run=run
  ucomp_rolling_synoptic_map, wave_regions[w], 'intensity', 'int', 'intensity', $
                              1.30, 'r13i', db, run=run

  ucomp_rolling_synoptic_map, wave_regions[w], 'linear polarization', 'linpol', $
                              'linpol', 1.08, 'r108l', db, run=run
  ucomp_rolling_synoptic_map, wave_regions[w], 'linear polarization', 'linpol', $
                              'linpol', 1.30, 'r13l', db, run=run

  ucomp_rolling_synoptic_map, wave_regions[w], 'radial azimuth', 'radazi', $
                              'radial_azimuth', 1.08, 'r108radazi', db, $
                              run=run
  ucomp_rolling_synoptic_map, wave_regions[w], 'radial azimuth', 'radazi', $
                              'radial_azimuth', 1.30, 'r13radazi', db, $
                              run=run

  ; doppler is not populated because of #33
  ; ucomp_rolling_synoptic_map, wave_regions[w], 'doppler velocity', 'doppler', $
  ;                             'doppler', 1.08, 'r108doppler', db, $
  ;                             run=run
  ; ucomp_rolling_synoptic_map, wave_regions[w], 'doppler velocity', 'doppler', $
  ;                             'doppler', 1.30, 'r13doppler', db, $
  ;                             run=run
endfor

obj_destroy, db
obj_destroy, run

end
