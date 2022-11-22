; docformat = 'rst'

;+
; Compute quality for the level 1 images for a given wave region.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_write_quality, wave_region, run=run
  compile_opt strictarr

  mg_log, 'checking quality for %s nm...', wave_region, name=run.logger_name, /info

  files = run->get_files(data_type='sci', wave_region=wave_region, count=n_files)
  if (n_files eq 0L) then begin
    mg_log, 'no files @ %s nm', wave_region, name=run.logger_name, /debug
    return
  endif

  quality_conditions = ucomp_quality_conditions(wave_region, run=run)

  ; write the quality log
  basename = string(run.date, wave_region, format='(%"%s.ucomp.%s.quality.log")')
  filename = filepath(basename, $
                      subdir=[run.date, 'level1'], $
                      root=run->config('processing/basedir'))
  openw, lun, filename, /get_lun
  printf, lun, 'Filename', 'Reason', format='(%"%-40s %-6s")'

  for f = 0L, n_files - 1L do begin
    printf, lun, files[f].l1_basename, files[f].quality_bitmask, format='(%"%-40s %6d")'
  endfor

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
