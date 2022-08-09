; docformat = 'rst'

pro ucomp_rolling_flat_plots, wave_region, db, run=run
  compile_opt strictarr

  query = 'select * from ucomp_cal where wave_region="%s" and opal=1 and caloptic=0 order by date_obs'
  data = db->query(query, wave_region, $
                   count=n_flats, error=error, fields=fields, sql_statement=sql)

  if (n_flats eq 0L) then begin
    mg_log, 'no flat data found', name=run.logger_name, /warn
    goto, done
  endif else begin
    mg_log, '%d flats found', n_flats, name=run.logger_name, /info
  endelse

  rcam_median_linecenter = data.rcam_median_linecenter
  rcam_median_continuum  = data.rcam_median_continuum
  tcam_median_linecenter = data.tcam_median_linecenter
  tcam_median_continuum  = data.tcam_median_continuum

  jds = ucomp_dateobs2julday(data.date_obs)
  format = '(C(CYI4.4, "-", CMoI2.2, "-", CDI2.2))'

  flat_range  = run->line(wave_region, 'flat_value_range')

  ; save original graphics settings
  original_device = !d.name

  ; setup graphics device
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=8, $
          set_resolution=[800, 2 * 300]

  tvlct, 0, 0, 0, 0
  tvlct, 255, 255, 255, 1
  tvlct, 255, 0, 0, 2
  tvlct, 0, 0, 255, 3
  tvlct, r, g, b, /get

  color            = 0
  background_color = 1
  camera0_color    = 2
  camera1_color    = 3
  
  camera0_psym     = 6
  camera1_psym     = 4
  symsize          = 0.25

  charsize = 1.0

  !p.multi = [0, 1, 2]

  !null = label_date(date_format='%Y-%N-%D')

  plot, jds, rcam_median_linecenter, /nodata, $
        charsize=charsize, title='Flat (not dark corrected) line center median counts vs. time', $
        color=color, background=background_color, $
        xtitle='Date', $
        xstyle=1, $
        xtickformat='label_date', $
        ytitle='Counts [DN]/NUMSUM', $
        ystyle=1, yrange=flat_range, ytickformat='ucomp_dn_format'
  mg_range_oplot, jds, $
                  flat_range[0] > [rcam_median_linecenter] < flat_range[1], $
                  psym=camera0_psym, symsize=symsize, $
                  linestyle=0, color=camera0_color, $
                  clip_color=camera0_color, clip_psym=7, clip_symsize=1.0
  mg_range_oplot, jds, $
                  flat_range[0] > [tcam_median_linecenter] < flat_range[1], $
                  psym=camera1_psym, symsize=symsize, $
                  linestyle=0, color=camera1_color, $
                  clip_color=camera1_color, clip_psym=7, clip_symsize=1.0
  xyouts, 0.95, 0.925, /normal, $
          'camera 0', alignment=1.0, color=camera0_color
  xyouts, 0.95, 0.9, /normal, $
          'camera 1', alignment=1.0, color=camera1_color

  plot, jds, rcam_median_continuum, /nodata, $
        charsize=charsize, title='Flat (not dark corrected) continuum median counts vs. time', $
        color=color, background=background_color, $
        xtitle='Time [HST]', $
        xstyle=1, $
        xtickformat='label_date', $
        ytitle='Counts [DN]/NUMSUM', $
        ystyle=1, yrange=flat_range, ytickformat='ucomp_dn_format'
  mg_range_oplot, jds, $
                  flat_range[0] > [rcam_median_continuum] < flat_range[1], $
                  psym=camera0_psym, symsize=symsize, $
                  linestyle=0, color=camera0_color, $
                  clip_color=camera0_color, clip_psym=7, clip_symsize=1.0
  mg_range_oplot, jds, $
                  flat_range[0] > [tcam_median_continuum] < flat_range[1], $
                  psym=camera1_psym, symsize=symsize, $
                  linestyle=0, color=camera1_color, $
                  clip_color=camera1_color, clip_psym=7, clip_symsize=1.0

  xyouts, 0.95, 0.425, /normal, $
          'camera 0', alignment=1.0, color=camera0_color
  xyouts, 0.95, 0.4, /normal, $
          'camera 1', alignment=1.0, color=camera1_color

  ; save plots image file
  output_filename = filepath(string(run.date, wave_region, $
                                    format='(%"%s.ucomp.%s.rolling.flats.gif")'), $
                             subdir=ucomp_decompose_date(run.date), $
                             root=run->config('engineering/basedir'))
  write_gif, output_filename, tvrd(), r, g, b

  done:
  !p.multi = 0
  if (n_elements(original_rgb) gt 0L) then tvlct, original_rgb
  if (n_elements(original_decomposed) gt 0L) then device, decomposed=original_decomposed
  if (n_elements(original_device) gt 0L) then set_plot, original_device
  
  mg_log, 'done', name=run.logger_name, /info
end


; main-level example program

date = '20220721'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
                           
run = ucomp_run(date, 'test', config_filename)

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

ucomp_rolling_flat_plots, '1074', db, run=run

end
