; docformat = 'rst'

;+
; Compute GBU (good/bad/ugly) for the level 1 images for a given wave region. 
;
; ::
;
;   1          at least two identical T_LCVR{1,2,3,4,5} temperatures
;
; :Params:
;   wave_region : in, required, type=string
;     wave region
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_check_gbu, wave_region, run=run
  compile_opt strictarr

  mg_log, 'checking GBU for %s nm...', wave_region, name=run.logger_name, /info

  files = run->get_files(data_type='sci', wave_region=wave_region, count=n_files)
  if (n_files eq 0L) then begin
    mg_log, 'no files @ %s nm', wave_region, name=run.logger_name, /debug
    return
  endif

  gbu_conditions = ucomp_gbu_conditions(wave_region, run=run)

  ; check various conditions to determine GBU
  for f = 0L, n_files - 1L do begin
    for g = 0L, n_elements(gbu_conditions) - 1L do begin
      files[f].gbu = gbu_conditions[g].mask * call_function(gbu_conditions[g].checker, $
                                                            files[f], $
                                                            run=run)
    endfor
  endfor

  ; write the GBU log
  basename = string(run.date, wave_region, format='(%"%s.ucomp.%s.gbu.log")')
  filename = filepath(basename, $
                      subdir=[run.date, 'level1'], $
                      root=run->config('processing/basedir'))
  openw, lun, filename, /get_lun
  printf, lun, 'Filename', 'Reason', format='(%"%-40s %-6s")'

  for f = 0L, n_files - 1L do begin
    printf, lun, files[f].l1_basename, files[f].gbu, format='(%"%-40s %6d")'
  endfor

  printf, lun
  printf, lun, 'GBU codes'
  printf, lun, 'Code', 'Description', format='(%"%-5s   %s")'
  for g = 0L, n_elements(gbu_conditions) - 1L do begin
    printf, lun, gbu_conditions[g].mask, gbu_conditions[g].description, $
            format='(%"%5d   %s")'
  endfor

  free_lun, lun

  done:
end
