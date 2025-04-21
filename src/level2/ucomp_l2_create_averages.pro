; docformat = 'rst'

;+
; Create average files for a wave region.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region to create average files for
;
; :Keywords:
;   average_filenames : out, optional, type=strarr
;     filenames of the average files produced
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_l2_create_averages, wave_region, $
                              average_filenames=average_filenames, $
                              run=run
  compile_opt strictarr

  l1_dir = filepath('', $
                    subdir=[run.date, 'level1'], $
                    root=run->config('processing/basedir'))
  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))

  if (~file_test(l2_dir, /directory)) then ucomp_mkdir, l2_dir, logger_name=run.logger_name

  program_names = run->get_programs(wave_region, count=n_programs)
  if (n_programs eq 0L) then begin
    mg_log, 'found no programs for %s nm science files', $
            wave_region, $
            name=run.logger_name, /info
    goto, done
  endif

  mg_log, 'found %s for %s nm science files', $
          mg_plural(n_programs, 'program'), wave_region, $
          name=run.logger_name, /info
  average_filenames = strarr(2, n_programs)   ; mean and median filenames
  for p = 0L, n_programs - 1L do begin
    program_files = run->get_files(wave_region=wave_region, $
                                   program=program_names[p], $
                                   count=n_files)
    if (n_files eq 0L) then begin
      mg_log, 'no %s nm files in %s', $
              wave_region, program_names[p], $
              name=run.logger_name, /info
      average_filenames[*, p] = ''
      continue
    endif

    ; filter out files with bad GBU
    good = bytarr(n_files)
    for f = 0L, n_files - 1L do good[f] = program_files[f].good
    good_files_indices = where(good eq 1, n_good_files)
    if (n_good_files eq 0L) then begin
      mg_log, 'no good %s nm files in %s', $
              wave_region, program_names[p], $
              name=run.logger_name, /info
      average_filenames[*, p] = ''
      continue
    endif

    good_files = program_files[good_files_indices]

    max_length = run->config('averaging/max_length')
    mg_log, 'max length: %0.1f secs', max_length, name=run.logger_name, /debug
    good_files = ucomp_l2_average_criteria(good_files, $
                                           program_names[p], $
                                           count=n_good_files, $
                                           max_length=max_length)

    mg_log, 'averaging %d %s nm files in %s', $
            n_good_files, wave_region, program_names[p], $
            name=run.logger_name, /info

    mean_average_basename = string(run.date, wave_region, program_names[p], $
                                   format='(%"%s.ucomp.%s.l1.%s.mean.fts")')
    mean_average_filename = filepath(mean_average_basename, root=l2_dir)
    median_average_basename = string(run.date, wave_region, program_names[p], $
                                     format='(%"%s.ucomp.%s.l1.%s.median.fts")')
    median_average_filename = filepath(median_average_basename, root=l2_dir)
    sigma_basename = string(run.date, wave_region, program_names[p], $
                                     format='(%"%s.ucomp.%s.l1.%s.sigma.fts")')
    sigma_filename = filepath(sigma_basename, root=l2_dir)

    average_filenames[0, p] = mean_average_filename
    average_filenames[1, p] = median_average_filename

    n_digits = floor(alog10(n_good_files)) + 1L
    for f = 0L, n_good_files - 1L do begin
      mg_log, mg_format('%*d/%d: %s', n_digits, /simple), $
              f + 1L, n_good_files, $
              file_basename(good_files[f].l1_basename), $
              name=run.logger_name, /debug
    endfor

    ; create the average
    good_filenames = strarr(n_good_files)
    for f = 0L, n_good_files - 1L do good_filenames[f] = good_files[f].l1_filename
    ucomp_average_l1_files, good_filenames, $
                            [mean_average_basename, $
                             median_average_filename, $
                             sigma_filename], $
                            min_average_files=run->config('averaging/min_average_files'), $
                            logger_name=run.logger_name, $
                            run=run
  endfor

  ; cull average_filenames
  average_filenames = average_filenames[where(average_filenames ne '', /null)]

  done:
end
