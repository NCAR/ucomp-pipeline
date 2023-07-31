; docformat = 'rst'

;+
; Compute GBU (good/bad/ugly) for the level 1 images for a given wave region.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_write_gbu, wave_region, run=run
  compile_opt strictarr

  mg_log, 'checking GBU for %s nm...', wave_region, name=run.logger_name, /info

  files = run->get_files(data_type='sci', wave_region=wave_region, count=n_files)
  if (n_files eq 0L) then begin
    mg_log, 'no files @ %s nm', wave_region, name=run.logger_name, /debug
    return
  endif

  gbu_conditions = ucomp_gbu_conditions(wave_region, run=run)

  ; write the GBU log
  basename = string(run.date, wave_region, format='(%"%s.ucomp.%s.gbu.log")')
  filename = filepath(basename, $
                      subdir=[run.date, 'level1'], $
                      root=run->config('processing/basedir'))
  openw, lun, filename, /get_lun
  printf, lun, 'Filename', 'Reason', 'Med Back', 'V Crosstalk', $
          format='(%"%-38s %6s %10s %13s")'

  for f = 0L, n_files - 1L do begin
    if (files[f].quality eq 0) then begin
      printf, lun, $
              files[f].l1_basename, $
              files[f].gbu, $
              files[f].median_background, $
              files[f].vcrosstalk_metric, $
              format='(%"%-38s %6d %10.3f %13.6f")'
    endif
  endfor

  printf, lun
  printf, lun, 'GBU bitmask codes'
  printf, lun, 'Code', 'Description', format='(%"%-5s   %s")'

  ; check to see if the epoch or wave region epoch value changed on this day
  date_range = [run.date, ucomp_increment_date(run.date)]

  for g = 0L, n_elements(gbu_conditions) - 1L do begin
    options = strsplit(gbu_conditions[g].values, ',', /extract, count=n_options)

    any_changed_value = 0B
    values = hash()
    for o = 0L, n_options - 1L do begin
      value_location = strmid(options[o], 0, 1)
      options[o] = strmid(options[o], 1)
      case value_location of
        'E': value = run->epoch(options[o], $
                                datetime=date_range, changed=changed)
        'W': value = run->line(wave_region, options[o], $
                               datetime=date_range, changed=changed)
        else: message, string(value_location, options[o], $
                              format='invalid location %s for option %s')
      endcase

      any_changed_value or= changed
      values[options[o]] = value
    endfor

    description = mg_subs(gbu_conditions[g].description, values)
    obj_destroy, values

    ; add an asterisk to the description if any value in the condition changed
    ; over the day
    if (any_changed_value) then description += '*'

    printf, lun, gbu_conditions[g].mask, description, format='(%"%5d   %s")'
  endfor

  printf, lun
  printf, lun, '* indicates that the threshold values changed on the day'

  free_lun, lun

  done:
end
