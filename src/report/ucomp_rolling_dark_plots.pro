; docformat = 'rst'

pro ucomp_rolling_dark_plots, db, run=run
  compile_opt strictarr

  query = 'select * from ucomp_cal where darkshutter=1 order by date_obs'
  data = db->query(query, $
                   count=n_darks, error=error, fields=fields, sql_statement=sql)

  if (n_darks eq 0L) then begin
    mg_log, 'no dark data found', name=run.logger_name, /warn
    goto, done
  endif else begin
    mg_log, '%d darks found', n_darks, name=run.logger_name, /info
  endelse

  rcam_median_linecenter = data.rcam_median_linecenter
  tcam_median_linecenter = data.tcam_median_linecenter

  jds = ucomp_dateobs2julday(data.date_obs)
  !null = label_date(date_format='%Y-%N-%D')

  dark_range  = run->epoch('dark_value_range', datetime=run.date)

  ; save original graphics settings
  original_device = !d.name

  ; setup graphics device
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=8, $
          set_resolution=[800, 300]

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

  plot, jds, rcam_median_linecenter, /nodata, $
        charsize=charsize, title='Dark median counts vs. time', $
        color=color, background=background_color, $
        xtitle='Date', $
        xstyle=1, $
        xtickformat='label_date', $
        ytitle='Counts [DN]/NUMSUM', $
        ystyle=1, yrange=dark_range, ytickformat='ucomp_dn_format'
  mg_range_oplot, jds, $
                  dark_range[0] > [rcam_median_linecenter] < dark_range[1], $
                  psym=camera0_psym, symsize=symsize, $
                  linestyle=0, color=camera0_color, $
                  clip_color=camera0_color, clip_psym=7, clip_symsize=1.0
  mg_range_oplot, jds, $
                  dark_range[0] > [tcam_median_linecenter] < dark_range[1], $
                  psym=camera1_psym, symsize=symsize, $
                  linestyle=0, color=camera1_color, $
                  clip_color=camera1_color, clip_psym=7, clip_symsize=1.0

  xyouts, 0.95, 0.85, /normal, $
          'camera 0', alignment=1.0, color=camera0_color
  xyouts, 0.95, 0.80, /normal, $
          'camera 1', alignment=1.0, color=camera1_color

  ; save plots image file
  output_filename = filepath(string(run.date, format='(%"%s.ucomp.rolling.darks.gif")'), $
                             subdir=ucomp_decompose_date(run.date), $
                             root=run->config('engineering/basedir'))
  write_gif, output_filename, tvrd(), r, g, b

  done:
  if (n_elements(original_rgb) gt 0L) then tvlct, original_rgb
  if (n_elements(original_decomposed) gt 0L) then device, decomposed=original_decomposed
  if (n_elements(original_device) gt 0L) then set_plot, original_device
  
  mg_log, 'done', name=run.logger_name, /info
end


; main-level example program

date = '20220804'
config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
                           
run = ucomp_run(date, 'test', config_filename)

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

ucomp_rolling_dark_plots, db, run=run

obj_destroy, [db, run]

end
