; docformat = 'rst'

pro ucomp_plot_camera_difference, start_date, end_date, wave_region, db
  compile_opt strictarr

  cmd = 'select file_name, date_obs, rcam_radius, tcam_radius from ucomp_eng where rcam_radius is not Null and date_obs > \"%s\" and date_obs < \"%s\" and wave_region = \"%s\" order by file_name;'

  results = db->query(cmd, start_date, end_date, wave_region, $
                      status=status, error_message=error_msg)

  jds = ucomp_dateobs2julday(results.date_obs)
  diffs = results.rcam_radius - results.tcam_radius

  !null = label_date(date_format='%Y-%N-%D')
  window, xsize=1200, ysize=600, /free
  mg_range_plot, jds, diffs, $
                 color='000000'x, background='ffffff'x, $
                 psym=4, symsize=0.5, $
                 title=string(wave_region, $
                              format='Camera radius difference for %s nm'), $
                 xtickformat='label_date', xtitle='Date', $
                 yrange=[-4.0, 4.0], ystyle=1, ytitle='Camera radius difference [px]', $
                 clip_color='0000ff'x, clip_psym=7, clip_symsize=0.25
  oplot, [jds[0], jds[-1]], fltarr(2), $
         color='ff0000'x, linestyle=0
end


; main-level example program

start_date = '20210715'
end_date = '20221110'
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

ucomp_plot_camera_difference, start_date, end_date, wave_region, db

obj_destroy, [run, db]

end
