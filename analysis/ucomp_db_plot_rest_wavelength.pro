; docformat = 'rst'

;+
; Query for rest wavelengths of files between the `start_date` and `end_date`
; in the given wave region and plot them.
;-
pro ucomp_db_plot_rest_wavelength, wave_region, start_date, end_date, db
  compile_opt strictarr

  sql_cmd = 'select date_obs, rest_wavelength from ucomp_file where date_obs between \"%s\" and \"%s\" and rest_wavelength is not NULL and wave_region=\"%s\" order by date_obs '

  _start_date = strjoin(ucomp_decompose_date(start_date), '-')
  _end_date = strjoin(ucomp_decompose_date(end_date), '-')

  results = db->query(sql_cmd, $
                      _start_date, $
                      _end_date, $
                      wave_region, $
                      status=status, error_message=error_msg)

  jds = ucomp_dateobs2julday(results.date_obs)
  rest_wavelength = results.rest_wavelength

  print, n_elements(jds), wave_region, $
         format='found %d %s nm level 2 files with rest wavelengths'

  charsize = 1.2
  !null = label_date(date_format='%Y-%N-%D')
  month_ticks = mg_tick_locator([jds[0], jds[-1]], /months)
  n_months = n_elements(month_ticks)
  if (n_months eq 0L) then begin
    month_ticks = 1L
  endif else begin
    max_ticks = 7
    n_minor = n_months / max_ticks > 1
    month_ticks = month_ticks[0:*:n_minor]
  endelse

  plot, jds, rest_wavelength, psym=4, symsize=0.5, $
        xstyle=1, xtickv=month_ticks, xticks=n_elements(month_ticks) - 1L, xminor=n_minor, $
        xtickformat='label_date', xtitle='Date', $
        ytitle='rest wavelength', $
        title=string(wave_region, _start_date, _end_date, $
                     format='Rest wavelengths for %s nm (%s to %s)'), $
        charsize=charsize

end

; main-level example program

; start_date = '20210715'
; end_date = '20221201'
start_date = '20220717'
end_date = '20221018'
wave_region = '1074'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(start_date, 'analysis', config_filename)
db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=logger_name, $
                      log_statements=log_statements, $
                      status=status)

ucomp_db_plot_rest_wavelength, wave_region, start_date, end_date, db

obj_destroy, [run, db]

end
