; docformat = 'rst'

;+
; Create a synoptic plot for the last 28 days.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region to produce a synoptic map for
;   name : in, required, type=string
;     human readable name for this type of synoptic plot
;   flag : in, required, type=string
;     filename flag for this type of synoptic plot
;   option_prefix : in, required, type=string
;     prefix for display parameters, i.e., option_prefix + '_display_min' in
;     the wave region configurations
;   height : in, required, type=float
;     height of annulus +/- 0.02 Rsun [Rsun]
;   field : in, required, type=string
;     field in ucomp_sci_{dynamics,polarization} table to retrieve data from
;   db : in, required, type=object
;     database connection
;
; :Keywords:
;   run : in, required, type=object
;     KCor run object
;-
pro ucomp_rolling_synoptic_map, wave_region, name, flag, option_prefix, $
                                height, field, db, $
                                run=run
  compile_opt strictarr

  n_days = 28   ; number of days to include in the plot

  mg_log, 'producing %d day %s synoptic plot', n_days, name, $
          name=run.logger_name, /info

  ; query database for data
  end_date_tokens = long(ucomp_decompose_date(run.date))
  end_date = string(end_date_tokens, format='(%"%04d-%02d-%02d")')
  end_date_jd = julday(end_date_tokens[1], $
                       end_date_tokens[2], $
                       end_date_tokens[0], $
                       0, 0, 0)
  start_date_jd = end_date_jd - n_days + 1
  start_date = string(start_date_jd, $
                      format='(C(CYI4.4, "-", CMoI2.2, "-", CDI2.2))')

  case option_prefix of
    'intensity': table = 'ucomp_sci_dynamics'
    'linpol': table = 'ucomp_sci_polarization'
    'radial_azimuth': table = 'ucomp_sci_dynamics'
    'doppler': table = 'ucomp_sci_dynamics'
  endcase

  query = 'select %s.date_obs, %s.%s from %s, mlso_numfiles where %s.wave_region=\"%s\" and %s.obsday_id=mlso_numfiles.day_id and mlso_numfiles.obs_day between ''%s'' and ''%s'''
  raw_data = db->query(query, table, table, field, table, table, wave_region, table, start_date, end_date, $
                       count=n_rows, error=error, fields=fields, sql_statement=sql)
  if (n_rows gt 0L) then begin
    mg_log, '%d dates between %s and %s', n_rows, start_date, end_date, $
            name=run.logger_name, /debug
  endif else begin
    mg_log, 'no data found between %s and %s', start_date, end_date, $
            name=run.logger_name, /warn
    goto, done
  endelse

  ; organize data
  product_data = raw_data.(1)

  dates = raw_data.date_obs
  n_dates = n_elements(dates)

  map = fltarr(n_days, 720) + !values.f_nan
  means = fltarr(n_days) + !values.f_nan
  for r = 0L, n_dates - 1L do begin
    decoded = *product_data[r]
    if (n_elements(decoded) gt 0L) then begin
      *product_data[r] = float(*product_data[r], 0, 720)   ; decode byte data to float
    endif

    date = dates[r]
    date_index = ucomp_dateobs2julday(date) - start_date_jd - 10.0 / 24.0
    date_index = floor(date_index)

    if (ptr_valid(product_data[r]) && n_elements(*product_data[r]) gt 0L) then begin
      map[date_index, *] = *product_data[r]
      means[date_index] = mean(*product_data[r])
    endif else begin
      map[date_index, *] = !values.f_nan
      means[date_index] = !values.f_nan
    endelse
  endfor

  ; configure device

  original_device = !d.name

  set_plot, 'Z'
  device, set_resolution=[(30 * n_days + 50) < 1200, 800]

  device, get_decomposed=original_decomposed
  device, decomposed=0

  n_colors = 252
  ucomp_loadct, option_prefix, n_colors=n_colors

  display_gamma = run->line(wave_region, option_prefix + '_display_gamma')
  mg_gamma_ct, display_gamma, /current, n_colors=n_colors

  display_min   = run->line(wave_region, option_prefix + '_display_min')
  display_max   = run->line(wave_region, option_prefix + '_display_max')
  display_power = run->line(wave_region, option_prefix + '_display_power')

  missing_color = 252
  tvlct, 0, 0, 0, missing_color
  background_color = 253
  tvlct, 255, 255, 255, background_color
  text_color = 254
  tvlct, 0, 0, 0, text_color
  detail_text_color = 255
  tvlct, 128, 128, 128, detail_text_color

  tvlct, rgb, /get

  if (option_prefix eq 'linpol') then map = alog10(map)

  nan_indices = where(finite(map) eq 0, n_nan)

  map = bytscl(map^display_power, $
               min=display_min^display_power, $
               max=display_max^display_power, $
               top=n_colors - 1L, $
               /nan)

  if (n_nan gt 0L) then map[nan_indices] = missing_color

  north_up_map = shift(map, 0, -180)
  east_limb = reverse(north_up_map[*, 0:359], 2)
  west_limb = north_up_map[*, 360:*]

  !null = label_date(date_format='%D %M %Z')
  jd_dates = dblarr(n_dates)
  for d = 0L, n_dates - 1L do jd_dates[d] = ucomp_dateobs2julday(dates[d])

  charsize = 0.9
  ;smooth_kernel = [11, 1]
  ;smooth_kernel = [3, 1]

  title = string(name, wave_region, height, start_date, end_date, $
                 format='(%"UCoMP synoptic map for %s at %s nm at r%0.2f from %s to %s")')
  erase, background_color
  mg_image, reverse(east_limb, 1), reverse(jd_dates), $
            xrange=[end_date_jd, start_date_jd], $
            xtyle=1, xtitle='Date (not offset for E limb)', $
            min_value=0.0, max_value=255.0, $
            /axes, yticklen=-0.005, xticklen=-0.01, $
            color=text_color, background=background_color, $
            title=string(title, format='(%"%s (East limb)")'), $
            xtickformat='label_date', $
            position=[0.05, 0.55, 0.97, 0.95], /noerase, $
            yticks=4, ytickname=['S', 'SE', 'E', 'NE', 'N'], yminor=4, $
            smooth_kernel=smooth_kernel, $
            charsize=charsize
  mg_image, reverse(west_limb, 1), reverse(jd_dates), $
            xrange=[end_date_jd, start_date_jd], $
            xstyle=1, xtitle='Date (not offset for W limb)', $
            min_value=0.0, max_value=255.0, $
            /axes, yticklen=-0.005, xticklen=-0.01, $
            color=text_color, background=background_color, $
            title=string(title, format='(%"%s (West limb)")'), $
            xtickformat='label_date', $
            position=[0.05, 0.05, 0.97, 0.45], /noerase, $
            yticks=4, ytickname=['S', 'SW', 'W', 'NW', 'N'], yminor=4, $
            smooth_kernel=smooth_kernel, $
            charsize=charsize

  xyouts, 0.97, 0.49, /normal, alignment=1.0, $
          string(display_min, display_max, display_power, $
                 format='(%"min/max/exp: %0.1f, %0.1f, %0.2f")'), $
          charsize=charsize, color=detail_text_color

  im = tvrd()

  eng_dir = filepath('', $
                     subdir=ucomp_decompose_date(run.date), $
                     root=run->config('engineering/basedir'))
  if (~file_test(eng_dir, /directory)) then file_mkdir, eng_dir

  gif_filename = filepath(string(run.date, $
                                 wave_region, $
                                 flag, $
                                 100.0 * height, $
                                 format='(%"%s.ucomp.%s.28day.synoptic.%s.r%03d.gif")'), $
                          root=eng_dir)
  write_gif, gif_filename, im, rgb[*, 0], rgb[*, 1], rgb[*, 2]

  mkhdr, primary_header, map, /extend
  sxdelpar, primary_header, 'DATE'
  ucomp_addpar, primary_header, 'DATE-OBS', start_date, $
                comment='[UTC] start date of synoptic map', $
                after='EXTEND'
  ucomp_addpar, primary_header, 'DATE-END', end_date, $
                comment='[UTC] end date of synoptic map', $
                format='(F0.2)', after='DATE-OBS'
  ucomp_addpar, primary_header, 'PRODUCT', name, $
                comment='name of product', $
                after='DATE-END'
  ucomp_addpar, primary_header, 'HEIGHT', height, $
                comment='[Rsun] height of annulus +/- 0.02 Rsun', $
                format='(F0.2)', after='DATE-END'

  fits_filename = filepath(string(run.date, $
                                  wave_region, $
                                  flag, $
                                  100.0 * height, $
                                  format='(%"%s.ucomp.%s.28day.synoptic.%s.r%03d.fts")'), $
                           root=eng_dir)
  writefits, fits_filename, float(map), primary_header

  ; clean up
  done:
  if (n_elements(rgb) gt 0L) then tvlct, rgb
  if (n_elements(original_decomposed) gt 0L) then device, decomposed=original_decomposed
  if (n_elements(original_device) gt 0L) then set_plot, original_device

  for d = 0L, n_elements(data) - 1L do begin
    s = raw_data[d]
    ptr_free, s.(1)
  endfor

  mg_log, 'done', name=run.logger_name, /info
end


; main-level example program

date = '20220901'
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

wave_regions = ['530', '637', '706', '789', '1074', '1079']
for w = 0L, n_elements(wave_regions) - 1L do begin
  ucomp_rolling_synoptic_map, wave_regions[w], 'intensity', 'int', 'intensity', $
                              1.08, 'r108i', db, run=run
  ucomp_rolling_synoptic_map, wave_regions[w], 'intensity', 'int', 'intensity', $
                              1.30, 'r13i', db, run=run

  ucomp_rolling_synoptic_map, wave_regions[w], 'linear polarization', 'linpol', $
                              'linpol', 1.08, 'r108l', db, run=run
  ucomp_rolling_synoptic_map, wave_regions[w], 'linear polarization', 'linpol', $
                              'linpol', 1.30, 'r13l', db, run=run

  ucomp_rolling_synoptic_map, wave_regions[w], 'radial azimuth', 'radazi', $
                              'radial_azimuth', 1.08, 'r108radazi', db, $
                              run=run
  ucomp_rolling_synoptic_map, wave_regions[w], 'radial azimuth', 'radazi', $
                              'radial_azimuth', 1.30, 'r13radazi', db, $
                              run=run

  ; doppler is not populated because of #33
  ; ucomp_rolling_synoptic_map, wave_regions[w], 'doppler velocity', 'doppler', $
  ;                             'doppler', 1.08, 'r108doppler', db, $
  ;                             run=run
  ; ucomp_rolling_synoptic_map, wave_regions[w], 'doppler velocity', 'doppler', $
  ;                             'doppler', 1.30, 'r13doppler', db, $
  ;                             run=run
endfor

obj_destroy, db
obj_destroy, run

end
