; docformat = 'rst'

;+
; Create average files for a wave region using a particular method, e.g.,
; "mean" or "median".
;
; :Params:
;   wave_region : in, required, type=string
;     wave region to create average files for
;   method : in, required, type=string
;     method of averaging, either "mean" or "median"
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_l2_create_averages, wave_region, method, run=run
  compile_opt strictarr

  l1_dir = filepath('', $
                    subdir=[run.date, 'level1'], $
                    root=run->config('processing/basedir'))
  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))

  program_names = run->get_programs(wave_region, count=n_programs)
  if (n_programs eq 0L) then begin
    mg_log, 'found no programs for %s nm science files', $
            wave_region, $
            name=run.logger_name, /info
    goto, done
  endif

  mg_log, 'found %d programs for %s nm science files', $
          n_programs, wave_region, $
          name=run.logger_name, /info
  for p = 0L, n_programs - 1L do begin
    program_files = run->get_files(wave_region=wave_region, $
                                   program=program_names[p], $
                                   count=n_files)
    if (n_files eq 0L) then begin
      mg_log, 'no %s nm files in %s', wave_region, program_names[p], $
              name=run.logger_name, /info
      continue
    endif

    mg_log, '%s averaging %d %s nm files in %s', $
            method, n_files, wave_region, program_names[p], $
            name=run.logger_name, /info

    average_basename = string(run.date, wave_region, program_names[p], method, $
                              format='(%"%s.ucomp.%s.%s.%s.fts")')
    average_filename = filepath(average_basename, root=l2_dir)

    for f = 0L, n_files - 1L do begin
      mg_log, '%03d/%d: %s', f + 1L, n_files, $
              file_basename(program_files[f].l1_basename), $
              name=run.logger_name, /debug
    endfor

    ucomp_average_l1_files, program_files, average_filename, method=method, run=run
  endfor

  done:
end
