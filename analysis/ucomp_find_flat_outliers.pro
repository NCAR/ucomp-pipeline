; docformat = 'rst'

pro ucomp_find_flat_outliers, wave_region, db, run=run
  compile_opt strictarr

  query = 'select * from ucomp_cal where wave_region=''%s'' and opal=1 and caloptic=0 order by date_obs'
  data = db->query(query, wave_region, $
                   count=n_flats, error=error, fields=fields, sql_statement=sql)

  jds = ucomp_dateobs2julday(data.date_obs)
  linecenter_range = run->line(wave_region, 'flat_value_linecenter_range')
  continuum_range = run->line(wave_region, 'flat_value_continuum_range')

  start_date = julday(2, 23, 2022, 19, 51, 17)

  indices = where((jds gt start_date) $
                    and ((data.rcam_median_linecenter lt linecenter_range[0]) $
                    or (data.rcam_median_linecenter gt linecenter_range[1]) $
                    or (data.tcam_median_linecenter lt linecenter_range[0]) $
                    or (data.tcam_median_linecenter gt linecenter_range[1]) $
                    or (data.rcam_median_continuum lt continuum_range[0]) $
                    or (data.rcam_median_continuum gt continuum_range[1]) $
                    or (data.tcam_median_continuum lt continuum_range[0]) $
                    or (data.tcam_median_continuum gt continuum_range[1])), count, /null)

  print, linecenter_range, format='line center range: %0.1f to %0.1f'
  print, continuum_range, format='continuum range: %0.1f to %0.1f'
  print, ['Filename', 'Quality', 'RCAM', 'TCAM', 'RCAM bkg', 'TCAM bkg'], $
         format='%-40s %-8s %-8s %-8s %-8s %-8s'
  print, mg_repstr('-', 40), mg_repstr('-', 8), mg_repstr('-', 8), mg_repstr('-', 8), $
         mg_repstr('-', 8), mg_repstr('-', 8), format='%-40s %-8s %-8s %-s %-8s %-8s'
  for f = 0L, count - 1L do begin
    print, data[indices[f]].file_name, $
           data[indices[f]].quality, $
           data[indices[f]].rcam_median_linecenter, $
           data[indices[f]].tcam_median_linecenter, $
           data[indices[f]].rcam_median_continuum, $
           data[indices[f]].tcam_median_continuum, $
           format='%-40s %8d %8.3f %8.3f %8.3f %8.3f'
  endfor
end


; main-level example program

date = '20220831'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, subdir=['..', 'config'], root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

wave_regions = run->all_lines()
for w = 0L, n_elements(wave_regions) - 1L do begin
  print, wave_regions[w], format='### %s nm outlier flats'
  ucomp_find_flat_outliers, wave_regions[w], db, run=run
endfor

obj_destroy, db
obj_destroy, run

end
