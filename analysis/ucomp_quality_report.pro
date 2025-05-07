; docformat = 'rst'

pro ucomp_quality_report, db, run=run
  compile_opt strictarr

  q = 'select * from ucomp_raw;'
  raw_files = db->query(q, count=n_raw_files)

  cal_indices = where(raw_files.datatype ne 'sci', n_cal_files)
  sci_indices = where(raw_files.datatype eq 'sci', n_sci_files)

  dash = (byte('-'))[0]

  cal_conditions = ucomp_cal_quality_conditions(wave_region, run=run)
  cal_masks = cal_conditions.mask
  cal_checkers = cal_conditions.checker
  cal_quality_bitmask = (raw_files[cal_indices]).quality_bitmask
  !null = where(cal_quality_bitmask ne 0, n_bad_cal_files)
  print, n_bad_cal_files, n_cal_files, 100.0 * n_bad_cal_files / n_cal_files, $
         format='Cal files failing quailty: %d/%d (%0.1d%%)'
  print, 'Mask', '# bad', 'Checking routine', format='%-4s %-6s %-35s'
  print, string(bytarr(4) + dash), string(bytarr(6) + dash), string(bytarr(35) + dash), $
         format='%-4s %-6s %-35s'
  for c = 0L, n_elements(cal_conditions) - 1L do begin
    !null = where(cal_quality_bitmask and cal_masks[c], n_condition)
    print, cal_masks[c], n_condition, cal_checkers[c], format='%4d %6d %-35s'
  endfor

  sci_conditions = ucomp_quality_conditions(wave_region, run=run)
  sci_masks = sci_conditions.mask
  sci_checkers = sci_conditions.checker
  sci_quality_bitmask = (raw_files[sci_indices]).quality_bitmask
  !null = where(sci_quality_bitmask ne 0, n_bad_sci_files)
  print, n_bad_sci_files, n_sci_files, 100.0 * n_bad_sci_files / n_sci_files, $
         format='Sci files failing quailty: %d/%d (%0.1d%%)'
  print, 'Mask', '# bad', 'Checking routine', format='%-4s %-6s %-35s'
  print, string(bytarr(4) + dash), string(bytarr(6) + dash), string(bytarr(35) + dash), $
         format='%-4s %-6s %-35s'
  for c = 0L, n_elements(sci_conditions) - 1L do begin
    !null = where(sci_quality_bitmask and sci_masks[c], n_condition)
    print, sci_masks[c], n_condition, sci_checkers[c], format='%4d %6d %-35s'
  endfor
end


; main-level example

start_date = '20210526'
end_date = '20221201'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(start_date, 'analysis', config_filename)

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

ucomp_quality_report, db, run=run

obj_destroy, [db, run]

end