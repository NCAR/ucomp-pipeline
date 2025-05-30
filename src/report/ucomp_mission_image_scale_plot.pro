; docformat = 'rst'

;+
; Plot IMAGESCL value over the mission.
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
pro ucomp_mission_image_scale_plot, wave_region, db, run=run
  compile_opt strictarr

  query = 'select ucomp_eng.date_obs, ucomp_eng.occltrid, ucomp_eng.image_scale, ucomp_eng.rcam_radius, ucomp_eng.tcam_radius from ucomp_eng inner join ucomp_file on ucomp_eng.file_name=ucomp_file.l0_file_name where ucomp_eng.wave_region = ''%s'' and ucomp_file.quality = 0 and ucomp_file.gbu = 0 order by ucomp_eng.date_obs'
  ;query = 'select * from ucomp_eng where wave_region=''%s'' order by date_obs'
  data = db->query(query, wave_region, $
                   count=n_files, error=error, fields=fields, sql_statement=sql)

  if (n_files eq 0L) then begin
    mg_log, 'no %s nm files found', wave_region, name=run.logger_name, /warn
    goto, done
  endif else begin
    mg_log, '%d %s nm files found', n_files, wave_region, $
            name=run.logger_name, /info
  endelse

  image_scale = data.image_scale
  plate_scale = 0.0 * image_scale
  plate_scale_tolerance = 0.0 * image_scale
  occulter_diameter = 0.0 * image_scale

  datetimes = ucomp_dateobs2datetime(data.date_obs)
  occulter_ids = 'OC-' + data.occltrid + '-mm'

  ; there are a lot of lookups needed to determine if/when the plate scale
  ; and occulter diameter changes -- this can take an hour for 1074 nm
  for f = 0L, n_files - 1L do begin
    plate_scale[f] = run->line(wave_region, 'plate_scale', $
                               datetime=datetimes[f])
    plate_scale_tolerance[f] = run->line(wave_region, 'plate_scale_tolerance', $
                                         datetime=datetimes[f])

    odiam = run->epoch(occulter_ids[f], datetime=datetimes[f], $
                       found=occulter_diameter_found)
    occulter_diameter[f] = occulter_diameter_found ? odiam : !values.f_nan
  endfor

  jds = ucomp_dateobs2julday(data.date_obs)

  !null = label_date(date_format='%Y-%N-%D')

  image_scale_range = [2.7, 3.2]

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
  tvlct, 255, 128, 128, 3
  tvlct, 240, 240, 240, 4
  tvlct, r, g, b, /get

  color            = 0
  background_color = 1
  clip_color       = 2
  platescale_color = 3
  tolerance_color  = 4

  psym             = 6
  symsize          = 0.25

  month_ticks = mg_tick_locator([jds[0], jds[-1]], /months)
  if (n_elements(month_ticks) eq 0L) then begin
    month_ticks = 1L
  endif else begin
    month_ticks = month_ticks[0:*:3]
  endelse

  mg_range_plot, [jds], [image_scale], $
                 charsize=charsize, $
                 title=string(wave_region, $
                              format='Image scale per %s nm file over the UCoMP mission'), $
                 color=color, background=background_color, $
                 psym=psym, symsize=symsize, $
                 clip_color=2, clip_psym=7, clip_symsize=1.0, $
                 xtitle='Date', $
                 xstyle=1, $
                 xtickformat='label_date', $
                 xtickv=month_ticks, $
                 xticks=n_elements(month_ticks) - 1L, $
                 xminor=3, $
                 ytitle='Image scale [arcsec/pixel]', $
                 ystyle=1, yrange=image_scale_range

  if (n_files gt 1L) then begin
    diffs = [0.0, plate_scale[1:-1] - plate_scale[0:-2]]
    change_indices = where(diffs gt 0.0, n_changes, /null)
    mg_log, '%d plate scale changes', n_changes, name=run.logger_name, /debug
    change_indices = [0L, change_indices, n_elements(plate_scale)]
    for c = 0L, n_changes do begin
      s = change_indices[c]
      e = change_indices[c+1] - 1
      polyfill, [jds[s:e], reverse(jds[s:e]), jds[s]], $
                [plate_scale[s:e] + plate_scale_tolerance, $
                 reverse(plate_scale[s:e] - plate_scale_tolerance), $
                 plate_scale[s] + plate_scale_tolerance], $
                color=tolerance_color
      plots, jds[s:e], plate_scale[s:e], linestyle=0, color=platescale_color
    endfor
  endif else begin
    plots, [jds], [plate_scale], linestyle=0, color=platescale_color
  endelse

  mg_range_oplot, jds, image_scale, $
                  color=color, $
                  psym=psym, symsize=symsize, $
                  clip_color=2, clip_psym=7, clip_symsize=1.0

  ; save plots image file
  output_filename = filepath(string(run.date, wave_region, $
                                    format='(%"%s.ucomp.%s.mission.image_scale.gif")'), $
                             subdir=ucomp_decompose_date(run.date), $
                             root=run->config('engineering/basedir'))
  write_gif, output_filename, tvrd(), r, g, b

  output_filename = filepath(string(run.date, wave_region, $
                                    format='(%"%s.ucomp.%s.mission.image_scale.csv")'), $
                             subdir=ucomp_decompose_date(run.date), $
                             root=run->config('engineering/basedir'))
  openw, lun, output_filename, /get_lun
  printf, lun, ['date/time', $
                'Julian date', $
                'RCAM radius', $
                'TCAM radius', $
                'image scale', $
                'plate scale', $
                'occulter ID', $
                'occulter diameter [mm]'], $
               format='%s, %s, %s, %s, %s, %s, %s, %s'
  for f = 0L, n_files - 1L do begin
    printf, lun, $
            (data.date_obs)[f], $
            jds[f], $
            (data.rcam_radius)[f], $
            (data.tcam_radius)[f], $
            image_scale[f], $
            plate_scale[f], $
            (data.occltrid)[f], $
            occulter_diameter[f], $
            format='%s, %0.9f, %0.3f, %0.3f, %0.5f, %0.5f, %s, %0.3f'
  endfor
  free_lun, lun

  done:
  if (n_elements(original_rgb) gt 0L) then tvlct, original_rgb
  if (n_elements(original_decomposed) gt 0L) then device, decomposed=original_decomposed
  if (n_elements(original_device) gt 0L) then set_plot, original_device

  mg_log, 'done', name=run.logger_name, /info
end


; main-level example program

date = '20240409'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

wave_region = '1079'

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

ucomp_mission_image_scale_plot, wave_region, db, run=run

obj_destroy, [db, run]

end
