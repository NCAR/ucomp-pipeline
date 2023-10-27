; docformat = 'rst'

pro ucomp_display_list, list_filename, $
                        root=root, $
                        output_filename=output_filename
  compile_opt strictarr

  data = read_csv(list_filename)
  basenames = data.field1
  dates = strmid(basenames, 0, 8)

  if (n_elements(output_filename) gt 0L) then begin
    openw, lun, output_filename, /get_lun
  endif else lun = -1

  for f = 0L, n_elements(basenames) - 1L do begin
    intensity_basename = file_basename(basenames, '.fts') + '.intensity.gif'
    filename = filepath(intensity_basename[f], $
                        subdir=ucomp_decompose_date(dates[f]), $
                        root=root)
    printf, lun, filename
  endfor

  if (n_elements(output_filename) gt 0L) then begin
    free_lun, lun
  endif
end


; main-level example program

; 1074 files with backgrounds bigger than 20.0
filename = 'ucomp.1074.good-high-bkgs.csv'
ucomp_display_list, filename, $
                    root='/hao/acos/fullres', $
                    output_filename='ucomp.1074.good-high-bkgs.lst'

end
