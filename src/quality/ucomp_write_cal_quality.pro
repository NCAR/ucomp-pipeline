; docformat = 'rst'

;+
; Write quality log for cal files.
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_write_cal_quality, run=run
  compile_opt strictarr

  dark_files = run->get_files(data_type='dark', count=n_dark_files)
  flat_files = run->get_files(data_type='flat', count=n_flat_files)
  cal_files  = run->get_files(data_type='cal', count=n_cal_files)

  ; write the quality log
  l1_dir = filepath('level1', subdir=run.date, root=run->config('processing/basedir'))
  if (~file_test(l1_dir, /directory)) then ucomp_mkdir, l1_dir

  basename = string(run.date, format='(%"%s.ucomp.cal.quality.log")')
  filename = filepath(basename, root=l1_dir)
  openw, lun, filename, /get_lun
  printf, lun, 'Filename', 'Type', 'Wave region', 'Reason', $
               format='(%"%-40s %-6s %-12s %-6s")'

  fmt = '(%"%-40s %-6s %-12s %6d")'
  for f = 0L, n_dark_files - 1L do begin
    printf, lun, file_basename(dark_files[f].raw_filename), $
                 'dark', $
                 dark_files[f].wave_region, $
                 dark_files[f].quality_bitmask, $
                 format=fmt
  endfor
  for f = 0L, n_flat_files - 1L do begin
    printf, lun, file_basename(flat_files[f].raw_filename), $
                 'flat', $
                 flat_files[f].wave_region, $
                 flat_files[f].quality_bitmask, $
                 format=fmt
  endfor
  for f = 0L, n_cal_files - 1L do begin
    printf, lun, file_basename(cal_files[f].raw_filename), $
                 'cal', $
                 cal_files[f].wave_region, $
                 cal_files[f].quality_bitmask, $
                 format=fmt
  endfor

  quality_conditions = ucomp_cal_quality_conditions(run=run)

  printf, lun
  printf, lun, 'Quality bitmask codes'
  printf, lun, 'Code', 'Description', format='(%"%-5s   %s")'
  for g = 0L, n_elements(quality_conditions) - 1L do begin
    printf, lun, quality_conditions[g].mask, quality_conditions[g].description, $
            format='(%"%5d   %s")'
  endfor

  free_lun, lun

  done:
end
