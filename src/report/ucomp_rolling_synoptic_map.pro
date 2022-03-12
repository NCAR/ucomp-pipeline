; docformat = 'rst'

;+
; Create a synoptic plot for the last 28 days.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region to produce a synoptic map for 
;   db : in, required, type=object
;     database connection
;
; :Keywords:
;   run : in, required, type=object]
;     KCor run object
;-
pro ucomp_rolling_synoptic_map, wave_region, name, flag, height, field, db, $
                                run=run
  compile_opt strictarr

  n_days = 28   ; number of days to include in the plot

  mg_log, 'producing synoptic plot of last %d days', n_days, $
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

  query = 'select ucomp_sci.date_obs, ucomp_sci.%s from ucomp_sci, mlso_numfiles where ucomp_sci.wave_region=\"%s\" and ucomp_sci.obsday_id=mlso_numfiles.day_id and mlso_numfiles.obs_day between ''%s'' and ''%s'''
  raw_data = db->query(query, field, wave_region, start_date, end_date, $
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
    date_index = ucomp_dateobs2julday(date) - start_date_jd - 10.0/24.0
    date_index = floor(date_index)

    if (ptr_valid(product_data[r]) && n_elements(*product_data[r]) gt 0L) then begin
      map[date_index, *] = *product_data[r]
      means[date_index] = mean(*product_data[r])
    endif else begin
      map[date_index, *] = !values.f_nan
      means[date_index] = !values.f_nan
    endelse
  endfor

  ; plot data
  set_plot, 'Z'
  device, set_resolution=[(30 * n_days + 50) < 1200, 800]
  original_device = !d.name

  device, get_decomposed=original_decomposed
  tvlct, rgb, /get
  device, decomposed=0

  range = mg_range(map)
  if (range[0] lt 0.0) then begin
    minv = 0.0
    maxv = range[1]

    loadct, 0, /silent
    foreground = 0
    background = 255
  endif else begin
    minv = 0.0
    maxv = range[1]

    loadct, 0, /silent
    foreground = 0
    background = 255
  endelse

  north_up_map = shift(map, 0, -180)
  east_limb = reverse(north_up_map[*, 0:359], 2)
  west_limb = north_up_map[*, 360:*]

  !null = label_date(date_format='%D %M %Z')
  jd_dates = dblarr(n_dates)
  for d = 0L, n_dates - 1L do jd_dates[d] = ucomp_dateobs2julday(dates[d])

  charsize = 0.9
  smooth_kernel = [11, 1]

  title = string(name, wave_region, start_date, end_date, $
                 format='(%"UCoMP synoptic map for %s at %s nm at r1.3 from %s to %s")')
  erase, background
  mg_image, reverse(east_limb, 1), reverse(jd_dates), $
            xrange=[end_date_jd, start_date_jd], $
            xtyle=1, xtitle='Date (not offset for E limb)', $
            min_value=minv, max_value=maxv, $
            /axes, yticklen=-0.005, xticklen=-0.01, $
            color=foreground, background=background, $
            title=string(title, format='(%"%s (East limb)")'), $
            xtickformat='label_date', $
            position=[0.05, 0.55, 0.97, 0.95], /noerase, $
            yticks=4, ytickname=['S', 'SE', 'E', 'NE', 'N'], yminor=4, $
            smooth_kernel=smooth_kernel, $
            charsize=charsize
  mg_image, reverse(west_limb, 1), reverse(jd_dates), $
            xrange=[end_date_jd, start_date_jd], $
            xstyle=1, xtitle='Date (not offset for W limb)', $
            min_value=minv, max_value=maxv, $
            /axes, yticklen=-0.005, xticklen=-0.01, $
            color=foreground, background=background, $
            title=string(title, format='(%"%s (West limb)")'), $
            xtickformat='label_date', $
            position=[0.05, 0.05, 0.97, 0.45], /noerase, $
            yticks=4, ytickname=['S', 'SW', 'W', 'NW', 'N'], yminor=4, $
            smooth_kernel=smooth_kernel, $
            charsize=charsize

  xyouts, 0.97, 0.485, /normal, alignment=1.0, $
          string(minv, maxv, format='(%"min/max: %0.3g, %0.3g")'), $
          charsize=charsize, color=128

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
  writefits, fits_filename, map, primary_header

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

date = '20220302'
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

ucomp_rolling_synoptic_map, '1074', 'linear polarization', 'linpol', 1.3, 'r13l', $
                            db, run=run
ucomp_rolling_synoptic_map, '1074', 'intensity', 'int', 1.08, 'r108i', $
                            db, run=run

obj_destroy, db
obj_destroy, run

end
