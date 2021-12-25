; docformat = 'rst'


function ucomp_platescale_fileinfo, filename, run=run
  compile_opt strictarr

  primary_header = headfits(filename, exten=0)

  occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
  wave_region = ucomp_getpar(primary_header, 'FILTER')
  radius = ucomp_getpar(primary_header, 'RADIUS')
  fit_chi_0 = ucomp_getpar(primary_header, 'FITCHI0')
  fit_chi_1 = ucomp_getpar(primary_header, 'FITCHI1')

  occulter_radius = run->epoch(string(occulter_id, format='OC-%s-mm')) / 2.0
  return, {occulter_id: occulter_id, $
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

  n_files = hash('530', 0, $
                 '637', 0, $
                 '656', 0, $
                 '691', 0, $
                 '706', 0, $
                 '789', 0, $
                 '1074', 0, $
                 '1079', 0, $
                 '1083', 0)

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
  good = orderedhash('530', list(), $
              '637', list(), $
              '656', list(), $
              '691', list(), $
              '706', list(), $
              '789', list(), $
              '1074', list(), $
              '1079', list(), $
              '1083', list())
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
      n_files[info.wave_region]++
      if (info.fit_chi_0 lt chi_limit[info.wave_region] $
            and info.fit_chi_1 lt chi_limit[info.wave_region]) then begin
        info.platescale = 2062.65 / info.mag / focal_length[info.wave_region]
        wave_region_list = good[info.wave_region]
        wave_region_list->add, info
      endif
    endfor

    date = ucomp_increment_date(date)
    run.datetime = string(date, format='%s.060000')
  endwhile

  foreach lst, good, wave_region do begin
    good_wave_region = good[wave_region]
    if (n_elements(good_wave_region) eq 0L) then continue
    good_wave_region = good_wave_region->toArray()
    print, wave_region, mean(good_wave_region.platescale), $
           n_elements(good_wave_region), n_files[wave_region], $
           format='%4s nm: plate scale: %0.6f pixels/arcsec (using %d/%d files)'
  endforeach

  foreach lst, good do obj_destroy, lst
  obj_destroy, [focal_length, chi_limit, good, n_files]
end


; main-level example program

; start_date = '20211101'
; end_date = '20220101'
start_date = '20211213'
end_date = '20211218'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(start_date, 'analysis', config_filename)

ucomp_platescale, start_date, end_date, run=run

obj_destroy, run

end
