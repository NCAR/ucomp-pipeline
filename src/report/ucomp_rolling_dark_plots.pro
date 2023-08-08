; docformat = 'rst'

;+
; Plot median dark value over the last year.
;
; :Params:
;   db : in, required, type=object
;     `UCoMPdbMySQL` object
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_rolling_dark_plots, db, run=run
  compile_opt strictarr

  date_components = long(ucomp_decompose_date(run.date))
  start_date = string(date_components[0] - 1, $
                      date_components[1], $
                      date_components[2], $
                      format='%04d-%02d-%02d')
  start_jd = julday(date_components[1], date_components[2], date_components[0] - 1, 0, 0, 0)
  end_date = string(date_components[0], $
                    date_components[1], $
                    date_components[2], $
                    format='%04d-%02d-%02d')
  end_jd = julday(date_components[1], date_components[2], date_components[0], 0, 0, 0)

  ; group the darks by gain mode and NUC value
  group_by_type = 0B

  if (group_by_type) then begin
    query = 'select * from ucomp_cal where darkshutter=1 and rcamnuc=''%s'' and gain_mode=''%s'' and date_obs > ''%sT00:00:00'' and date_obs < ''%sT00:00:00'' order by date_obs'
    gain_mode = ['high', 'low']
    m = 0
    rcamnuc = ['normal', 'Offset + gain corrected']
    n = 1
    data = db->query(query, rcamnuc[n], gain_mode[m], start_date, end_date, $
                     count=n_darks, error=error, fields=fields, sql_statement=sql)
  endif else begin
    query = 'select * from ucomp_cal where darkshutter=1 and date_obs > ''%sT00:00:00'' and date_obs < ''%sT00:00:00'' order by date_obs'
    data = db->query(query, start_date, end_date, $
                     count=n_darks, error=error, fields=fields, sql_statement=sql)
  endelse

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
          set_resolution=[600, 1000]

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

  charsize = 1.4

  if (group_by_type) then begin
    charsize = 0.8
    title = string(gain_mode[m], rcamnuc[n], start_date, $
                   format='(%"Dark median counts (gain mode %s, NUC %s) vs. time since %s")')
  endif else begin
    title = string(start_date, format='(%"Dark median counts vs. time since %s")')
  endelse
  month_ticks = mg_tick_locator([start_jd, end_jd], /months)
  month_ticks = month_ticks[0:*:3]

  !p.multi = [0, 1, 4]

  plot, jds, rcam_median_linecenter, /nodata, $
        charsize=charsize, $
        title=title, $
        color=color, background=background_color, $
        xtitle='Date', $
        xstyle=1, xrange=[start_jd, end_jd], $
        xtickformat='label_date', $
        xtickv=month_ticks, $
        xticks=n_elements(month_ticks) - 1L, $
        xminor=3, $
        ytitle='Counts [DN]/NUMSUM', $
        ystyle=1, yrange=dark_range, ytickformat='ucomp_dn_format'
  mg_range_oplot, jds, $
                  dark_range[0] > [rcam_median_linecenter] < dark_range[1], $
                  psym=camera0_psym, symsize=symsize, $
                  linestyle=0, color=camera0_color, $
                  clip_color=camera0_color, clip_psym=7, clip_symsize=3.0 * symsize
  mg_range_oplot, jds, $
                  dark_range[0] > [tcam_median_linecenter] < dark_range[1], $
                  psym=camera1_psym, symsize=symsize, $
                  linestyle=0, color=camera1_color, $
                  clip_color=camera1_color, clip_psym=7, clip_symsize=3.0 * symsize

  xyouts, 0.95, 0.555, /normal, $
          'camera 0 (RCAM)', alignment=1.0, color=camera0_color
  xyouts, 0.95, 0.540, /normal, $
          'camera 1 (TCAM)', alignment=1.0, color=camera1_color

  !p.multi = [6, 2, 4]

  tarr_range = run->epoch('dark_arr_temp_range', datetime=run.date)
  tpcb_range = run->epoch('dark_pcb_temp_range', datetime=run.date)

  query = 'select * from ucomp_cal inner join ucomp_raw on ucomp_cal.file_name = ucomp_raw.file_name where ucomp_cal.darkshutter=1 and ucomp_cal.exptime = 80.0 and ucomp_cal.rcamnuc=''Offset + gain corrected'' and ucomp_cal.gain_mode=''high'' and ucomp_cal.date_obs > ''%s'' order by ucomp_cal.date_obs'
  data = db->query(query, start_date, $
                   count=n_darks, error=error, fields=fields, sql_statement=sql)

  plot, data.t_c0arr, data.rcam_median_linecenter, /nodata, $
        charsize=charsize, $
        title='Dark sensor temperature vs. median counts', $
        psym=camera0_psym, symsize=symsize, $
        color=color, background=background_color, $
        xtitle='Sensor array temperature [C]', $
        xstyle=1, xrange=tarr_range, $
        ytitle='Counts [DN]/NUMSUM', $
        ystyle=1, yrange=dark_range, ytickformat='ucomp_dn_format'
   mg_range_oplot, data.t_c0arr, data.rcam_median_linecenter, $
                   psym=camera0_psym, symsize=symsize, $
                   color=camera0_color, $
                   clip_color=camera0_color, clip_psym=7, clip_symsize=3.0 * symsize
   mg_range_oplot, data.t_c1arr, data.tcam_median_linecenter, $
                   psym=camera1_psym, symsize=symsize, $
                   color=camera1_color, $
                   clip_color=camera1_color, clip_psym=7, clip_symsize=3.0 * symsize

   plot, data.t_c0pcb, data.rcam_median_linecenter, /nodata, $
         charsize=charsize, $
         title='Dark PCB temperature vs. median counts', $
         psym=camera0_psym, symsize=symsize, $
         color=color, background=background_color, $
         xtitle='PCB temperature [C]', $
         xstyle=1, xrange=tpcb_range, $
         ytitle='Counts [DN]/NUMSUM', $
         ystyle=1, yrange=dark_range, ytickformat='ucomp_dn_format'
   mg_range_oplot, data.t_c0pcb, data.rcam_median_linecenter, $
                   psym=camera0_psym, symsize=symsize, $
                   color=camera0_color, $
                   clip_color=camera0_color, clip_psym=7, clip_symsize=3.0 * symsize
   mg_range_oplot, data.t_c1pcb, data.tcam_median_linecenter, $
                   psym=camera1_psym, symsize=symsize, $
                   color=camera1_color, $
                   clip_color=camera1_color, clip_psym=7, clip_symsize=3.0 * symsize

  !p.multi = [2, 1, 4]
  jds = ucomp_dateobs2julday(data.date_obs)
  month_ticks = mg_tick_locator([start_jd, end_jd], /months)
  month_ticks = month_ticks[0:*:3]

  plot, jds, data.rcam_median_linecenter / data.t_c0arr, /nodata, $
        charsize=charsize, $
        title='Dark median counts / sensor temperature', $
        psym=camera0_psym, symsize=symsize, $
        color=color, background=background_color, $
        xtitle='Date', $
        xstyle=1, xrange=[start_jd, end_jd], $
        xtickformat='label_date', $
        xtickv=month_ticks, $
        xticks=n_elements(month_ticks) - 1L, $
        xminor=3, $
        ytitle='Counts [DN]/sensor temperature [C]', $
        ystyle=1, $
        yrange=dark_range / reverse(tarr_range)
   mg_range_oplot, jds, data.rcam_median_linecenter / data.t_c0arr, $
                   psym=camera0_psym, symsize=symsize, $
                   color=camera0_color, $
                   clip_color=camera0_color, clip_psym=7, clip_symsize=3.0 * symsize
   mg_range_oplot, jds, data.tcam_median_linecenter / data.t_c1arr, $
                   psym=camera1_psym, symsize=symsize, $
                   color=camera1_color, $
                   clip_color=camera1_color, clip_psym=7, clip_symsize=3.0 * symsize

  plot, jds, data.rcam_median_linecenter / data.t_c0pcb, /nodata, $
        charsize=charsize, $
        title='Dark median counts / PCB temperature', $
        psym=camera0_psym, symsize=symsize, $
        color=color, background=background_color, $
        xtitle='Date', $
        xstyle=1, xrange=[start_jd, end_jd], $
        xtickformat='label_date', $
        xtickv=month_ticks, $
        xticks=n_elements(month_ticks) - 1L, $
        xminor=3, $
        ytitle='Counts [DN]/PCB temperature [C]', $
        ystyle=1, $
        yrange=dark_range / reverse(tpcb_range)
   mg_range_oplot, jds, data.rcam_median_linecenter / data.t_c0pcb, $
                   psym=camera0_psym, symsize=symsize, $
                   color=camera0_color, $
                   clip_color=camera0_color, clip_psym=7, clip_symsize=3.0 * symsize
   mg_range_oplot, jds, data.tcam_median_linecenter / data.t_c1pcb, $
                   psym=camera1_psym, symsize=symsize, $
                   color=camera1_color, $
                   clip_color=camera1_color, clip_psym=7, clip_symsize=3.0 * symsize

  ; save plots image file
  output_filename = filepath(string(run.date, format='(%"%s.ucomp.yearly.darks.gif")'), $
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

date = '20210922'
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

ucomp_rolling_dark_plots, db, run=run

obj_destroy, [db, run]

end
