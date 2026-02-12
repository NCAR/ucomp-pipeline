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

  query = 'select distinct occltrid from ucomp_eng where ucomp_eng.wave_region = ''%s'';'
  unique_occulter_ids = db->query(query, wave_region, error=error)
  unique_occulter_ids = unique_occulter_ids.occltrid
  unique_occulter_ids = unique_occulter_ids[where(unique_occulter_ids ne '', n_occulters, /null)]

  query = 'select ucomp_eng.date_obs, ucomp_eng.occltrid, ucomp_eng.image_scale, ucomp_eng.rcam_radius, ucomp_eng.tcam_radius from ucomp_eng inner join ucomp_file on ucomp_eng.file_name=ucomp_file.l0_file_name where ucomp_eng.wave_region = ''%s'' and ucomp_file.quality = 0 and ucomp_file.gbu = 0 order by ucomp_eng.date_obs'
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
  occulter_ids_mm = 'OC-' + data.occltrid + '-mm'

  jds = ucomp_dateobs2julday(data.date_obs)

  plate_scale_changes = run->line_changes(wave_region, 'plate_scale')
  plate_scale_tolerance_changes = run->line_changes(wave_region, 'plate_scale_tolerance')

  unique_occulter_ids_mm = occulter_ids_mm[uniq(occulter_ids_mm, sort(occulter_ids))]
  for i = 0L, n_elements(unique_occulter_ids_mm) - 1L do begin
    ; the below assumes the size of a given occulter ID does not change over
    ; the mission in the epoch file
    odiam = run->epoch(unique_occulter_ids_mm[i], datetime=datetimes[0], $
                       found=occulter_diameter_found)
    occulter_diameter_value = occulter_diameter_found ? odiam : !values.f_nan
    indices = where(occulter_ids_mm eq unique_occulter_ids_mm[i], /null)
    occulter_diameter[indices] = occulter_diameter_value
  endfor

  n_plate_scale_changes = n_elements(plate_scale_changes)
  plate_scale_change_stats = replicate({start_jd: 0.0D, end_jd: 0.0D, value: 0.0}, $
                                       n_plate_scale_changes)

  for c = 0L, n_plate_scale_changes - 1L do begin
    change = plate_scale_changes[c]
    if (change.datetime eq 'DEFAULT') then begin
      plate_scale_change_stats[c].start_jd = jds[0]
      index = 0
    endif else begin
      change_dt = mg_epoch_parse_datetime(change.datetime)
      plate_scale_change_stats[c].start_jd = change_dt.to_julian()
      index = value_locate(jds, change_dt.to_julian()) + 1L
      obj_destroy, change_dt
    endelse
    plate_scale_change_stats[c].value = change.value
    if (index lt n_elements(plate_scale) - 1L) then begin
      plate_scale[index:*] = change.value
    endif
  endfor

  for c = 0L, n_elements(plate_scale_tolerance_changes) - 1L do begin
    change = plate_scale_tolerance_changes[c]
    if (change.datetime eq 'DEFAULT') then index = 0 else begin
      change_dt = mg_epoch_parse_datetime(change.datetime)
      index = value_locate(jds, change_dt.to_julian()) + 1L
      obj_destroy, change_dt
    endelse
    if (index lt n_elements(plate_scale) - 1L) then begin
      plate_scale_tolerance[index:*] = change.value
    endif
  endfor
  mg_log, 'finished finding epoch changes', name=run.logger_name, /info

  !null = label_date(date_format='%Y-%N-%D')

  image_scale_range = [2.7, 3.2]

  ; save original graphics settings
  original_device = !d.name

  ; setup graphics device
  set_plot, 'Z'
  device, get_decomposed=original_decomposed
  tvlct, original_rgb, /get
  width = 1200
  height = 450
  device, decomposed=0, $
          set_pixel_depth=8, $
          set_resolution=[width, height]

  tvlct, 0, 0, 0, 0
  tvlct, 255, 255, 255, 1
  tvlct, 255, 0, 0, 2
  tvlct, 255, 128, 128, 3
  tvlct, 240, 240, 240, 4

  ; need at least n_occulters different colors
  loadct, 48, bottom=5, ncolors=12   ; color table 48 is CB-Set3
  ; starting at 7 instead of 5 to skip a difficult-to-see yellow at index 6
  occulter_color_offset = 7

  tvlct, r, g, b, /get

  color            = 0
  background_color = 1
  clip_color       = 2
  platescale_color = 3
  tolerance_color  = 4

  psym             = 6
  symsize          = 0.25

  month_ticks = mg_tick_locator([jds[0], jds[-1]], /months)
  n_months = n_elements(month_ticks)
  if (n_elements(month_ticks) eq 0L) then begin
    month_ticks = 1L
    n_minor = 1L
  endif else begin
    max_ticks = 7L
    n_minor = n_months / max_ticks > 1
    month_ticks = month_ticks[0:*:n_minor]
  endelse

  mg_range_plot, [jds], [image_scale], /nodata, $
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
                 xminor=n_minor, $
                 xticklen=0.01 * (float(width) / float(height)), $
                 ytitle='Image scale [arcsec/pixel]', $
                 ystyle=1, yrange=image_scale_range, $
                 yticklen=0.01

  if (n_files gt 1L) then begin
    diffs = [0.0, plate_scale[1:-1] - plate_scale[0:-2]]
    change_indices = where(diffs gt 0.0, n_changes, /null)
    mg_log, '%s', $
            mg_plural(n_changes, 'plate scale change', 'plate scale changes'), $
            name=run.logger_name, /debug
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

  ygap = 15.0
  for o = 0L, n_occulters - 1L do begin
    occulter_indices = where(data.occltrid eq unique_occulter_ids[o], n_occulter_datapts)
    if (n_occulter_datapts gt 0L) then begin
      mg_range_oplot, jds[occulter_indices], image_scale[occulter_indices], $
                      color=occulter_color_offset + o, $
                      psym=psym, symsize=symsize, $
                      clip_color=2, clip_psym=7, clip_symsize=1.0
      xyouts, width - 150.0, height - 50.0 - o * ygap, string(unique_occulter_ids[o], format='Occulter %s'), $
              /device, charsize=1.0, color=occulter_color_offset + o
    endif
  endfor

  xgap = 0.015 * (jds[-1] - jds[0])
  stat_height = 2.78   ; in plate scale units
  for c = 0L, n_plate_scale_changes - 1L do begin
    start_jd = plate_scale_change_stats[c].start_jd
    end_jd = c ge (n_plate_scale_changes - 1) ? jds[-1] : plate_scale_change_stats[c + 1].start_jd
    epoch_indices = where(jds ge start_jd and jds lt end_jd, n_epoch_indices, /null)

    if (n_epoch_indices gt 0L) then begin
      platescale_mean = mean(image_scale[epoch_indices], /nan)
      platescale_median = median(image_scale[epoch_indices])
      platescale_stddev = stddev(image_scale[epoch_indices], /nan)

      xyouts, end_jd - xgap, stat_height, alignment=1.0, $   ;start_jd + xgap, stat_height, $
              string(plate_scale_change_stats[c].value, $
                     platescale_mean, $
                     platescale_median, $
                     platescale_stddev, $
                     format='nominal: %0.3f!Cmean: %0.3f!Cmedian: %0.3f!Cstd dev: %0.3f'), $
              charsize=0.9, color=0
    endif else begin
      mg_log, 'epoch with no %s nm data: %s-%s', $
              wave_region, $
              plate_scale_changes[c].datetime, $
              c eq n_plate_scale_changes - 1L ? '' : plate_scale_changes[c + 1].datetime, $
              name=run.logger_name, /warn
    endelse
  endfor

  ; save plots image file
  output_filename = filepath(string(run.date, wave_region, $
                                    format='(%"%s.ucomp.%s.mission.image_scale.gif")'), $
                             subdir=ucomp_decompose_date(run.date), $
                             root=run->config('engineering/basedir'))
  write_gif, output_filename, tvrd(), r, g, b
  mg_log, 'wrote %s', file_basename(output_filename), name=run.logger_name, /info

  output_filename = filepath(string(run.date, wave_region, $
                                    format='(%"%s.ucomp.%s.mission.image_scale.csv")'), $
                             subdir=ucomp_decompose_date(run.date), $
                             root=run->config('engineering/basedir'))
  column_names = ['date/time', $
                  'Julian date', $
                  'RCAM radius', $
                  'TCAM radius', $
                  'image scale', $
                  'plate scale', $
                  'occulter ID', $
                  'occulter diameter [mm]']
  write_csv, output_filename, $
             data.date_obs, $
             jds, $
             data.rcam_radius, $
             data.tcam_radius, $
             image_scale, $
             plate_scale, $
             data.occltrid, $
             occulter_diameter, $
             header=column_names
  mg_log, 'wrote %s', file_basename(output_filename), name=run.logger_name, /info

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

wave_region = '1074'

db = ucomp_db_connect(run->config('database/config_filename'), $
                      run->config('database/config_section'), $
                      logger_name=run.logger_name, $
                      log_statements=run->config('database/log_statements'), $
                      status=status)

overall_start = systime(/seconds)
ucomp_mission_image_scale_plot, wave_region, db, run=run
print, systime(/seconds) - overall_start, format='overall time: %0.1f secs'

obj_destroy, [db, run]

end
