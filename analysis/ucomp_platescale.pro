; docformat = 'rst'


function ucomp_platescale_dateobs2jd, date_obs
  compile_opt strictarr

  year   = long(strmid(date_obs, 0, 4))
  month  = long(strmid(date_obs, 5, 2))
  day    = long(strmid(date_obs, 8, 2))
  hour   = long(strmid(date_obs, 11, 2))
  minute = long(strmid(date_obs, 14, 2))
  second = long(strmid(date_obs, 17, 2))
  return, julday(month, day, year, hour, minute, second)
end


function ucomp_platescale_date2jd, date
  compile_opt strictarr

  date_parts = long(ucomp_decompose_date(date))
  return, julday(date_parts[1], date_parts[2], date_parts[0])
end


function ucomp_platescale_compute, radius, occulter_radius, focal_length
  compile_opt strictarr

  return, 2062.65 / (0.01 * radius / occulter_radius) / focal_length
end


function ucomp_platescale_fileinfo, filename, run=run
  compile_opt strictarr

  primary_header = headfits(filename, exten=0)

  date_obs = ucomp_getpar(primary_header, 'DATE-OBS')
  occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
  wave_region = ucomp_getpar(primary_header, 'FILTER')
  radius = ucomp_getpar(primary_header, 'RADIUS')
  fit_chi_0 = ucomp_getpar(primary_header, 'FITCHI0')
  fit_chi_1 = ucomp_getpar(primary_header, 'FITCHI1')

  occulter_radius = run->epoch(string(occulter_id, format='OC-%s-mm')) / 2.0
  return, {date_obs: date_obs, $
           occulter_id: occulter_id, $
           occulter_radius: occulter_radius, $
           mag: 0.01 * radius / occulter_radius, $
           platescale: 0.0, $
           wave_region: wave_region, $
           radius: radius, $
           fit_chi_0: fit_chi_0, $
           fit_chi_1: fit_chi_1}
end


pro ucomp_platescale, start_date, end_date, run=run
  compile_opt strictarr

  n_files = hash('530', hash(), $
                 '637', hash(), $
                 '656', hash(), $
                 '691', hash(), $
                 '706', hash(), $
                 '789', hash(), $
                 '1074', hash(), $
                 '1079', hash(), $
                 '1083', hash())

  focal_length = hash('530', 2226.62, $
                      '637', 2245.68, $
                      '656', 2248.35, $
                      '691', 2252.96, $
                      '706', 2254.69, $
                      '789', 2263.51, $
                      '1074', 2285.48, $
                      '1079', 2285.82, $
                      '1083', 2286.04)

  chi_limit = hash('530', 5.0, $
                   '637', 10.0, $
                   '656', 3.0, $
                   '691', 5.0, $
                   '706', 5.0, $
                   '789', 2.0, $
                   '1074', 0.5, $
                   '1079', 0.5, $
                   '1083', 5.0)
  good = orderedhash('530', hash(), $
                     '637', hash(), $
                     '656', hash(), $
                     '691', hash(), $
                     '706', hash(), $
                     '789', hash(), $
                     '1074', hash(), $
                     '1079', hash(), $
                     '1083', hash())
  process_basedir = run->config('processing/basedir')

  date = start_date
  run.datetime = string(date, format='%s.060000')

  while (date ne end_date) do begin
    print, date, format='#### %s'
    l1_glob = filepath('*.ucomp.*.l1.*.fts', $
                       subdir=[date, 'level1'], $
                       root=process_basedir)
    l1_files = file_search(l1_glob, count=n_l1_files)

    for f = 0L, n_l1_files - 1L do begin
      info = ucomp_platescale_fileinfo(l1_files[f], run=run)
      wave_region_hash = good[info.wave_region]
      if (~wave_region_hash.hasKey(info.occulter_id)) then begin
        wave_region_hash[info.occulter_id] = list()
        (n_files[info.wave_region])[info.occulter_id] = 0L
      endif
      (n_files[info.wave_region])[info.occulter_id]++
      if (info.fit_chi_0 lt chi_limit[info.wave_region] $
            and info.fit_chi_1 lt chi_limit[info.wave_region]) then begin
        info.platescale = 2062.65 / info.mag / focal_length[info.wave_region]
        occulter_list = wave_region_hash[info.occulter_id]
        occulter_list->add, info
      endif
    endfor

    date = ucomp_increment_date(date)
    run.datetime = string(date, format='%s.060000')
  endwhile

  time_range = [ucomp_platescale_date2jd(start_date), $
                ucomp_platescale_date2jd(end_date)]
  radius_range = [340.0, 355.0]
  charsize = 1.0

  !null = label_date(date_format='%Y-%N-%D')

  foreach good_wave_region, good, wave_region do begin
    if (n_elements(good_wave_region) eq 0L) then continue
    title = string(wave_region, format='%s nm radii')
    window, xsize=800, ysize=300, title=title, /free
    plot, findgen(10), /nodata, charsize=charsize, $
          title=title, $
          xrange=time_range, yrange=radius_range, ytitle='radius [pixels]', $
          xtickformat='label_date'
    foreach occulter_list, good_wave_region, occulter_id do begin
      if (n_elements(occulter_list) gt 0L) then begin
        occulter_array = occulter_list->toArray()
        mean_radius = mean(occulter_array.radius)
        oplot, ucomp_platescale_dateobs2jd(occulter_array.date_obs), $
               occulter_array.radius, psym=3
        mean_platescale = ucomp_platescale_compute(mean_radius, $
                                                   occulter_array[0].occulter_radius, $
                                                   focal_length[wave_region])
        print, wave_region, occulter_id, mean_radius, mean_platescale, $
               n_elements(occulter_list), (n_files[wave_region])[occulter_id], $
               format='%4s nm [occulter ID: %s]: radius: %0.3f, plate scale: %0.6f arcsec/pixels (%d/%d files)'
      endif
    endforeach
  endforeach

  foreach h, good do begin
    foreach lst, h do obj_destroy, lst
    obj_destroy, h
  endforeach
  foreach h, n_files do obj_destroy, h
  obj_destroy, [focal_length, chi_limit, good, n_files]
end


; main-level example program

;  637 nm: plate scale: 2.932629 arcsec/pixels (using 190/271 files)
;  656 nm: plate scale: 2.905706 arcsec/pixels (using 52/403 files)
;  789 nm: plate scale: 2.884677 arcsec/pixels (using 164/222 files)
; 1074 nm: plate scale: 2.815336 arcsec/pixels (using 2052/2655 files)
; 1079 nm: plate scale: 2.814214 arcsec/pixels (using 176/185 files)

; start_date = '20210903'
; end_date = '20220101'
start_date = '20211001'
end_date = '20211026'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(start_date, 'analysis', config_filename)

ucomp_platescale, start_date, end_date, run=run

obj_destroy, run

end
