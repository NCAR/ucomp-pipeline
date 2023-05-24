; docformat = 'rst'


function ucomp_platescale_fileinfo, filename
  compile_opt strictarr

  primary_header = headfits(filename, exten=0)

  date_obs = ucomp_getpar(primary_header, 'DATE-OBS')
  occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
  image_scale = ucomp_getpar(primary_header, 'CDELT1')
  wave_region = ucomp_getpar(primary_header, 'FILTER')
  fit_chi_0 = ucomp_getpar(primary_header, 'FITCHI0')
  fit_chi_1 = ucomp_getpar(primary_header, 'FITCHI1')

  return, {date_obs: date_obs, $
           jd: ucomp_dateobs2julday(date_obs), $
           occulter_id: occulter_id, $
           image_scale: image_scale, $
           wave_region: wave_region, $
           fit_chi_0: fit_chi_0, $
           fit_chi_1: fit_chi_1}
end


pro ucomp_platescale, start_date, end_date, process_basedir
  compile_opt strictarr

  wave_regions = ['530', '637', '656', '670', '691', '706', '761', '789', $
                  '802', '991', '1074', '1079', '1083']
  n_wave_regions = n_elements(wave_regions)
  wave_region_luns = lonarr(n_wave_regions)

  for w = 0L, n_wave_regions - 1L do begin
    filename = string(wave_regions[w], format='ucomp.%s.image_scale.txt')
    openw, lun, filename, /get_lun
    wave_region_luns[w] = lun
  endfor

  date = start_date
  while (date ne end_date) do begin
    print, date, format='%s'

    l1_glob = filepath('*.ucomp.*.l1.*.fts', $
                       subdir=[date, 'level1'], $
                       root=process_basedir)
    l1_files = file_search(l1_glob, count=n_l1_files)

    for f = 0L, n_l1_files - 1L do begin
      info = ucomp_platescale_fileinfo(l1_files[f])
      indices = where(info.wave_region eq wave_regions, count)
      if (count gt 0L) then begin
        printf, wave_region_luns[indices[0]], $
                info.jd, info.occulter_id, info.image_scale, info.fit_chi_0, info.fit_chi_1, $
                format='%0.5f %s %0.5f %0.7f %0.7f'
      endif
    endfor

    date = ucomp_increment_date(date)
  endwhile

  for w = 0L, n_wave_regions - 1L do free_lun, wave_region_luns[w]
end


; main-level example program


start_date = '20210526'
end_date = '20221201'
process_basedir = '/hao/corona3/Data/UCoMP/Steve/process'

ucomp_platescale, start_date, end_date, process_basedir

end
