; docformat= 'rst'

pro ucomp_find_largest_offset_diff, file1, file2
  compile_opt strictarr

  n_lines1 = file_lines(file1)
  n_lines2 = file_lines(file2)

  if (n_lines1 ne n_lines2) then message, 'files don''t have same length'

  data1 = strarr(n_lines1)
  data2 = strarr(n_lines2)

  openr, lun1, file1, /get_lun
  readf, lun1, data1
  free_lun, lun1

  openr, lun2, file2, /get_lun
  readf, lun2, data2
  free_lun, lun2

  filenames = strarr(n_lines1)

  xoffset0_1 = fltarr(n_lines1)
  yoffset0_1 = fltarr(n_lines1)
  xoffset1_1 = fltarr(n_lines1)
  yoffset1_1 = fltarr(n_lines1)

  xoffset0_2 = fltarr(n_lines2)
  yoffset0_2 = fltarr(n_lines2)
  xoffset1_2 = fltarr(n_lines2)
  yoffset1_2 = fltarr(n_lines2)

  for i = 0L, n_lines1 - 1L do begin
    tokens1 = strsplit(data1[i], /extract)
    tokens2 = strsplit(data2[i], /extract)

    filenames[i] = tokens1[0]

    xoffset0_1[i] = tokens1[1]
    yoffset0_1[i] = tokens1[2]
    xoffset1_1[i] = tokens1[3]
    yoffset1_1[i] = tokens1[4]

    xoffset0_2[i] = tokens2[1]
    yoffset0_2[i] = tokens2[2]
    xoffset1_2[i] = tokens2[3]
    yoffset1_2[i] = tokens2[4]
  endfor

  error = sqrt((xoffset0_1 - xoffset0_2)^2 + (yoffset0_1 - yoffset0_2)^2) $
    + sqrt((xoffset1_1 - xoffset1_2)^2 + (yoffset1_1 - yoffset1_2)^2)

  sorted_indices = sort(-error)
  error = error[sorted_indices]
  filenames = filenames[sorted_indices]

  n = 5
  s = mg_zip(filenames[0:n - 1], error[0:n - 1])
  print, s, format='%s -> %0.6f'
end


; main-level example program

ucomp_find_largest_offset_diff, 'ucomp.1074.nominal-offsets.txt', $
                                'ucomp.1074.vanessa-offsets.txt'

end
