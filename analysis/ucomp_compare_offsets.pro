; docformat = 'rst'

pro ucomp_compare_offsets, wave_region, dir1, dir2
  compile_opt strictarr

  glob = string(wave_region, format='*.%s.l1.?.fts')
  l1_files = file_search(filepath(glob, root=dir1), count=n_l1_files)

  keywords = ['XOFFSET0', 'YOFFSET0', 'XOFFSET1', 'YOFFSET1']

  diffs = fltarr(n_elements(keywords), n_l1_files) + !values.f_nan
  for f = 0L, n_l1_files - 1L do begin
    compare_file = filepath(file_basename(l1_files[f]), root=dir2)
    if (~file_test(compare_file, /regular)) then continue
    fits_open, l1_files[f], fcb1
    fits_read, fcb1, !null, primary_header1, exten_no=0
    fits_close, fcb1

    fits_open, compare_file, fcb2
    fits_read, fcb2, !null, primary_header2, exten_no=0
    fits_close, fcb2

    values1 = fltarr(n_elements(keywords))
    values2 = fltarr(n_elements(keywords))
    for k = 0L, n_elements(keywords) - 1L do begin
      values1[k] = ucomp_getpar(primary_header1, keywords[k])
      values2[k] = ucomp_getpar(primary_header2, keywords[k])
    endfor
    diffs[*, f] = values1 - values2
    print, file_basename(l1_files[f]), values1, values2, values1 - values2, $
           format='%15s %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f'
  endfor

  print, mean(abs(diffs), dimension=2, /nan)
  print, median(abs(diffs), dimension=2)
end

; main-level example program

wave_region = '1074'

;dates = ['20210817', '20220225', '20220901', '20221125']
dates = ['20210817', '20220225', '20221125']

for d = 0L, n_elements(dates) - 1L do begin
  dir1 = string(dates[d], format='/hao/dawn/Data/UCoMP/process/%s/level1')
  dir2 = string(dates[d], format='/hao/corona3/Data/UCoMP/Steve/process/%s/level1')

  print, dates[d], format='## %s'
  ucomp_compare_offsets, wave_region, dir1, dir2
  print
endfor

end
