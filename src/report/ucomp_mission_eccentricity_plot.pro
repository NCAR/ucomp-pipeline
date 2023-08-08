; docformat = 'rst'

;+
; Plot eccentricity values over the mission.
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
pro ucomp_mission_eccentricity_plot, wave_region, db, run=run
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

  rcam_eccentricity = data.rcam_eccentricity
  tcam_eccentricity = data.tcam_eccentricity

  jds = ucomp_dateobs2julday(data.date_obs)
  !null = label_date(date_format='%Y-%N-%D')

  ; save original graphics settings
  original_device = !d.name

  ; setup graphics device
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  device, decomposed=0, $
          set_pixel_depth=8, $
          set_resolution=[800, 600]

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

  eccentricity_range = [0.0, 1.0]
  time_range = [jds[0], jds[-1]]

  month_ticks = mg_tick_locator(time_range, /months)
  if (n_elements(month_ticks) eq 0L) then begin
    month_ticks = 1L
  endif else begin
    month_ticks = month_ticks[0:*:3]
  endelse

  !p.multi = [0, 1, 2, 0, 0]

  mg_range_plot, [jds], [rcam_eccentricity], $
                 charsize=charsize, $
                 title=string(wave_region, $
                              format='RCAM occulter eccentricity per %s nm file over the UCoMP mission'), $
                 color=color, background=background_color, $
                 psym=psym, symsize=symsize, $
                 clip_color=2, clip_psym=7, clip_symsize=1.0, $
                 xtitle='Date', $
                 xstyle=1, range=time_range, $
                 xtickformat='label_date', $
                 xtickv=month_ticks, $
                 xticks=n_elements(month_ticks) - 1L, $
                 xminor=3, $
                 ytitle='Eccentricity', $
                 ystyle=1, yrange=eccentricity_range

  mg_range_plot, [jds], [tcam_eccentricity], $
                 charsize=charsize, $
                 title=string(wave_region, $
                              format='TCAM occulter eccentricity per %s nm file over the UCoMP mission'), $
                 color=color, background=background_color, $
                 psym=psym, symsize=symsize, $
                 clip_color=2, clip_psym=7, clip_symsize=1.0, $
                 xtitle='Date', $
                 xstyle=1, range=time_range, $
                 xtickformat='label_date', $
                 xtickv=month_ticks, $
                 xticks=n_elements(month_ticks) - 1L, $
                 xminor=3, $
                 ytitle='Eccentricity', $
                 ystyle=1, yrange=eccentricity_range

  !p.multi = 0

  ; save plots image file
  output_filename = filepath(string(run.date, wave_region, $
                                    format='(%"%s.ucomp.%s.mission.eccentricity.gif")'), $
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

ucomp_mission_eccentricity_plot, '1074', db, run=run

obj_destroy, [db, run]

end
