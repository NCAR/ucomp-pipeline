; docformat = 'rst'

;+
; Plot centering values over the mission.
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
pro ucomp_mission_centering_plot, wave_region, db, run=run
  compile_opt strictarr

  query = 'select * from ucomp_eng where wave_region=''%s'' order by date_obs'
  data = db->query(query, wave_region, $
                   count=n_files, error=error, fields=fields, sql_statement=sql)

  if (n_files eq 0L) then begin
    mg_log, 'no %s nm files found', wave_region, name=run.logger_name, /warn
    goto, done
  endif else begin
    mg_log, '%d %s nm files found', n_files, wave_region, name=run.logger_name, /info
  endelse

  rcam_radius = data.rcam_radius
  tcam_radius = data.tcam_radius

  rcam_occulter_chisq = data.rcam_occulter_chisq
  tcam_occulter_chisq = data.tcam_occulter_chisq

  jds = ucomp_dateobs2julday(data.date_obs)
  !null = label_date(date_format='%Y-%N-%D')

  gbu_max_fit_chisq = run->line(wave_region, 'gbu_max_fit_chisq')
  fit_chisq_range = [0.0, 2.0 * gbu_max_fit_chisq]

  ; save original graphics settings
  original_device = !d.name

  ; setup graphics device
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=8, $
          set_resolution=[1600, 800]

  tvlct, 0, 0, 0, 0
  tvlct, 255, 255, 255, 1
  tvlct, 255, 0, 0, 2
  tvlct, 255, 128, 128, 3
  tvlct, 240, 240, 240, 4
  tvlct, r, g, b, /get

  color            = 0
  background_color = 1
  clip_color       = 2

  charsize         = 0.9
  psym             = 6
  symsize          = 0.25

  r_range    = 340.0 + 20.0 * [-1.0, 1.0]
  time_range = [jds[0], jds[-1]]

  month_ticks = mg_tick_locator(time_range, /months)
  n_months = n_elements(month_ticks)
  if (n_months eq 0L) then begin
    month_ticks = 1L
  endif else begin
    max_ticks = 7
    n_minor = n_months / max_ticks
    month_ticks = month_ticks[0:*:n_minor]
  endelse

  !p.multi = [0, 2, 2, 0, 0]

  mg_range_plot, [jds], [rcam_radius], $
                 charsize=charsize, $
                 title=string(wave_region, $
                              format='RCAM radius for %s nm files over the UCoMP mission'), $
                 color=color, background=background_color, $
                 psym=psym, symsize=symsize, $
                 clip_color=2, clip_psym=7, clip_symsize=1.0, $
                 xtitle='Date', $
                 xstyle=1, range=time_range, $
                 xtickformat='label_date', $
                 xtickv=month_ticks, $
                 xticks=n_elements(month_ticks) - 1L, $
                 xminor=n_minor, $
                 ytitle='Radius [pixels]', $
                 ystyle=1, yrange=r_range

  mg_range_plot, [jds], [tcam_radius], $
                  charsize=charsize, $
                  title=string(wave_region, $
                               format='TCAM radius for %s nm files over the UCoMP mission'), $
                  color=color, background=background_color, $
                  psym=psym, symsize=symsize, $
                  clip_color=2, clip_psym=7, clip_symsize=1.0, $
                  xtitle='Date', $
                  xstyle=1, range=time_range, $
                  xtickformat='label_date', $
                  xtickv=month_ticks, $
                  xticks=n_elements(month_ticks) - 1L, $
                  xminor=n_minor, $
                  ytitle='Radius [pixels]', $
                  ystyle=1, yrange=r_range

  mg_range_plot, [jds], [rcam_occulter_chisq], $
                 charsize=charsize, $
                 title=string(wave_region, $
                              format='RCAM occulter fit chi-squared for %s nm files over the UCoMP mission'), $
                 color=color, background=background_color, $
                 psym=psym, symsize=symsize, $
                 clip_color=2, clip_psym=7, clip_symsize=1.0, $
                 xtitle='Date', $
                 xstyle=1, range=time_range, $
                 xtickformat='label_date', $
                 xtickv=month_ticks, $
                 xticks=n_elements(month_ticks) - 1L, $
                 xminor=3, $
                 ytitle='Chi-squared', $
                 ystyle=1, yrange=fit_chisq_range

  plots, [jds[0], jds[-1]], fltarr(2) + gbu_max_fit_chisq, linestyle=3, color=color

  mg_range_plot, [jds], [tcam_occulter_chisq], $
                 charsize=charsize, $
                 title=string(wave_region, $
                              format='TCAM occulter fit chi-squared for %s nm files over the UCoMP mission'), $
                 color=color, background=background_color, $
                 psym=psym, symsize=symsize, $
                 clip_color=2, clip_psym=7, clip_symsize=1.0, $
                 xtitle='Date', $
                 xstyle=1, range=time_range, $
                 xtickformat='label_date', $
                 xtickv=month_ticks, $
                 xticks=n_elements(month_ticks) - 1L, $
                 xminor=3, $
                 ytitle='Chi-squared', $
                 ystyle=1, yrange=fit_chisq_range

  plots, [jds[0], jds[-1]], fltarr(2) + gbu_max_fit_chisq, linestyle=3, color=color

  !p.multi = 0

  ; save plots image file
  output_filename = filepath(string(run.date, wave_region, $
                                    format='(%"%s.ucomp.%s.mission.centering.gif")'), $
                             subdir=ucomp_decompose_date(run.date), $
                             root=run->config('engineering/basedir'))
  write_gif, output_filename, tvrd(), r, g, b

  device, set_resolution=[1000, 400]

  mg_range_plot, [jds], [rcam_radius - tcam_radius], $
                 charsize=charsize, $
                 title=string(wave_region, $
                              format='RCAM - TCAM radius difference for %s nm files over the UCoMP mission'), $
                 color=color, background=background_color, $
                 psym=psym, symsize=symsize, $
                 clip_color=2, clip_psym=7, clip_symsize=1.0, $
                 xtitle='Date', $
                 xstyle=1, range=time_range, $
                 xtickformat='label_date', $
                 xtickv=month_ticks, $
                 xticks=n_elements(month_ticks) - 1L, $
                 xminor=3, $
                 ytitle='RCAM - TCAM radius difference [pixels]', $
                 ystyle=1, yrange=[-2.0, 2.0]
  plots, time_range, fltarr(2), linestyle=3, color=color

  output_filename = filepath(string(run.date, wave_region, $
                                    format='(%"%s.ucomp.%s.mission.radius-diff.gif")'), $
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

date = '20250324'
wave_region = '1074'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

ucomp_mission_centering_plot, wave_region, db, run=run

obj_destroy, [db, run]

end
