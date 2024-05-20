; docformat = 'rst'

;+
; Plot median flat value over the last year.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region, e.g., "1074"
;   db : in, required, type=object
;     `UCoMPdbMySQL` object
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_rolling_flat_plots, wave_region, db, run=run
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

  query = 'select * from ucomp_eng where wave_region=''%s'' and date_obs > ''%sT00:00:00'' and date_obs < ''%sT00:00:00'' order by date_obs'
  data = db->query(query, wave_region, start_date, end_date, $
                   count=n_flats, error=error, fields=fields, sql_statement=sql)

  if (n_flats eq 0L) then begin
    mg_log, 'no flat data found', name=run.logger_name, /warn
    goto, done
  endif else begin
    mg_log, '%d %s nm flats found', n_flats, wave_region, $
            name=run.logger_name, /info
  endelse

  rcam_median_linecenter = data.flat_rcam_median_linecenter
  rcam_median_continuum  = data.flat_rcam_median_continuum
  tcam_median_linecenter = data.flat_tcam_median_linecenter
  tcam_median_continuum  = data.flat_tcam_median_continuum

  jds = ucomp_dateobs2julday(data.date_obs)
  format = '(C(CYI4.4, "-", CMoI2.2, "-", CDI2.2))'

  flat_range       = run->line(wave_region, 'flat_value_display_range') - 50.0
  linecenter_range = run->line(wave_region, 'flat_value_linecenter_range') - 50.0
  continuum_range  = run->line(wave_region, 'flat_value_continuum_range') - 50.0

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

  charsize = 0.9

  !p.multi = [0, 1, 2]

  !null = label_date(date_format='%Y-%N-%D')

  month_ticks = mg_tick_locator([start_jd, end_jd], /months)
  if (n_elements(month_ticks) gt 0L) then month_ticks = month_ticks[0:*:3]

  plot, [jds], [rcam_median_linecenter], /nodata, $
        charsize=charsize, $
        title=string(wave_region, start_date, $
                     format='%s nm dark corrected flat line center median counts vs. time since %s'), $
        color=color, background=background_color, $
        xtitle='Date', $
        xstyle=1, xrange=[start_jd, end_jd], $
        xtickformat='label_date', $
        xtickv=month_ticks, $
        xticks=n_elements(month_ticks) gt 0L ? n_elements(month_ticks) - 1L : 5L, $
        xminor=3, $
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
          'camera 0 (RCAM)', alignment=1.0, color=camera0_color
  xyouts, 0.95, 0.9, /normal, $
          'camera 1 (TCAM)', alignment=1.0, color=camera1_color

  plots, [start_jd, end_jd], fltarr(2) + linecenter_range[0], linestyle=3, color=color
  plots, [start_jd, end_jd], fltarr(2) + linecenter_range[1], linestyle=3, color=color

  plot, [jds], [rcam_median_continuum], /nodata, $
        charsize=charsize, $
        title=string(wave_region, start_date, $
                     format='%s nm dark corrected flat continuum median counts vs. time since %s'), $
        color=color, background=background_color, $
        xtitle='Time [HST]', $
        xstyle=1, xrange=[start_jd, end_jd], $
        xtickformat='label_date', $
        xtickv=month_ticks, $
        xticks=n_elements(month_ticks) gt 0L ? n_elements(month_ticks) - 1L : 5L, $
        xminor=3, $
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
          'camera 0 (RCAM)', alignment=1.0, color=camera0_color
  xyouts, 0.95, 0.4, /normal, $
          'camera 1 (TCAM)', alignment=1.0, color=camera1_color

  plots, [start_jd, end_jd], fltarr(2) + continuum_range[0], linestyle=3, color=color
  plots, [start_jd, end_jd], fltarr(2) + continuum_range[1], linestyle=3, color=color

  ; save plots image file
  output_filename = filepath(string(run.date, wave_region, $
                                    format='(%"%s.ucomp.%s.yearly.flats.gif")'), $
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
