; docformat = 'rst'

;+
; Check the files of the wave region against the median of the files from the
; same program.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region to process
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_l1_check_gbu_median_diff, wave_region, run=run
  compile_opt strictarr

  mg_log, 'starting...', name=run.logger_name, /info

  conditions = ucomp_gbu_conditions(wave_region, run=run)
  indices = where(conditions.checker eq 'ucomp_gbu_median_diff')
  gbu_mask = conditions[indices[0]].mask

  l1_dir = filepath('', $
                    subdir=[run.date, 'level1'], $
                    root=run->config('processing/basedir'))

  ; find programs
  program_names = run->get_programs(wave_region, count=n_programs)
  if (n_programs eq 0L) then begin
    mg_log, 'found no programs for %s nm science files', $
            wave_region, $
            name=run.logger_name, /info
    goto, done
  endif

  ; average good (so far) files by program
  for p = 0L, n_programs - 1L do begin
    program_files = run->get_files(wave_region=wave_region, $
                                   program=program_names[p], $
                                   count=n_files)
    if (n_files eq 0L) then begin
      mg_log, 'no %s nm files in %s [%s]', $
              wave_region, program_names[p], method, $
              name=run.logger_name, /info
      average_filenames[p] = ''
      continue
    endif

    ; filter out files with bad (so far) GBU
    good = bytarr(n_files)
    for f = 0L, n_files - 1L do good[f] = program_files[f].good && program_files[f].wrote_l1
    good_files_indices = where(good eq 1, n_good_files)
    if (n_good_files eq 0L) then begin
      mg_log, 'no good %s nm files in %s', $
              wave_region, program_names[p], $
              name=run.logger_name, /info
      continue
    endif

    good_files = program_files[good_files_indices]

    radius = fltarr(n_good_files)
    post_angle = fltarr(n_good_files)
    for f = 0L, n_good_files - 1L do begin
      mg_log, 'file %d/%d: %s', $
              f + 1, n_good_files, good_files[f].l1_basename, $
              name=run.logger_name, /debug
      radius[f] = good_files[f].occulter_radius
      post_angle[f] = good_files[f].post_angle
    endfor
    median_radius = median(radius)
    median_post_angle = median(post_angle)

    mg_log, 'median radius: %0.1f', median_radius, name=run.logger_name, /debug
    mg_log, 'median post angle: %0.1f', median_post_angle, name=run.logger_name, /debug

    ucomp_average_l1_files, good_files, method='mean', averaged_data=mean_data, run=run
    ucomp_average_l1_files, good_files, method='median', averaged_data=median_data, run=run
    ucomp_average_l1_files, good_files, method='sigma', averaged_data=sigma_data, run=run

    dims = size(mean_data, /dimensions)
    mask = ucomp_annulus(1.1 * median_radius, 1.5 * median_radius, dimensions=dims)
    mask *= ucomp_post_mask(dims, median_post_angle, post_width=60.0)
    !null = where(mask ne 0, n_zero_mask)
    mg_log, 'n_zero_mask: %d', n_zero_mask, name=run.logger_name, /debug
    mg_log, 'mean data range: %0.2f - %0.2f', mg_range(mean_data), name=run.logger_name, /debug
    mg_log, 'median data range: %0.2f - %0.2f', mg_range(median_data), name=run.logger_name, /debug
    mg_log, 'sigma data range: %0.2f - %0.2f', mg_range(sigma_data), name=run.logger_name, /debug

    ; for each good file, compute its number of standard deviations from the median
    for f = 0L, n_files - 1L do begin
      if (~program_files[f].wrote_l1) then continue

      mg_log, '%s', program_files[f].l1_basename, name=run.logger_name, /debug

      ; mark files bad if larger than threshold number of standard deviations
      ucomp_read_l1_data, filepath(program_files[f].l1_basename, root=l1_dir), $
                          primary_header=primary_header, $
                          ext_data=ext_data, $
                          ext_headers=ext_headers, $
                          n_wavelengths=n_wavelengths

      unique_wavelengths = program_files[f].unique_wavelengths
      dims = size(ext_data, /dimensions)
      sigma = fltarr(dims[2], dims[3]) + !values.f_nan

      for p = 0L, dims[2] - 1L do begin
        for w = 0L, dims[3] - 1L do begin
          !null = where((sigma_data[*, *, p, w] eq 0.0) or (mask eq 0), $
                        complement=nonzero_indices, ncomplement=n_nonzero)
          mg_log, 'n_nonzero: %d', n_nonzero, name=run.logger_name, /debug
          if (n_nonzero gt 0L) then begin
            diff = abs(ext_data[*, *, p, w] - median_data[*, *, p, w]) / sigma_data[*, *, p, w]
            sigma[p, w] = median(diff[nonzero_indices])
          endif
        endfor
      endfor

      for w = 0L, dims[3] - 1L do begin
        mg_log, 'sigma @ %0.2f nm: %s', $
                unique_wavelengths[w], $
                strjoin(string(sigma[*, w], format='%0.2f'), ', '), $
                name=run.logger_name, /debug
      endfor

      program_files[f].max_sigma = max(sigma, /nan)
      if (program_files[f].max_sigma gt run->line(wave_region, 'gbu_max_stddev')) then begin
        program_files[f].gbu = gbu_mask
      endif
    endfor
  endfor

  done:
  mg_log, 'done', name=run.logger_name, /info
end
