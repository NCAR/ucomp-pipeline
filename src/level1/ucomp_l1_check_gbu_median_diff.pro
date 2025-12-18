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

  mask = ucomp_gbu_mask(run->config('gbu/mask'), wave_region, run=run) $
           and ucomp_gbu_mask(run->epoch('gbu_mask'), wave_region, run=run)

  conditions = ucomp_gbu_conditions(wave_region, run=run)
  indices = where(conditions.checker eq 'ucomp_gbu_median_diff')

  if (~mask[indices[0]]) then goto, done

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

  mg_log, 'found %s: %s', $
          mg_plural(n_programs, 'program'), $
          strjoin(program_names, ', '), $
          name=run.logger_name, /info

  ; average good (so far) files by program
  for program_number = 0L, n_programs - 1L do begin
    program_files = run->get_files(wave_region=wave_region, $
                                   program=program_names[program_number], $
                                   count=n_files)
    if (n_files eq 0L) then begin
      mg_log, 'no %s nm files in %s', $
              wave_region, program_names[program_number], $
              name=run.logger_name, /info
      continue
    endif else begin
      mg_log, 'checking %d %s nm files in %s', $
              n_files, wave_region, program_names[program_number], $
              name=run.logger_name, /info
    endelse

    ; filter out files with bad (so far) GBU
    good = bytarr(n_files)
    for f = 0L, n_files - 1L do begin
      good[f] = program_files[f].good && program_files[f].wrote_l1
    endfor
    good_files_indices = where(good eq 1, n_good_files)
    if (n_good_files eq 0L) then begin
      mg_log, 'no good %s nm files in %s', $
              wave_region, program_names[program_number], $
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

    good_filenames = strarr(n_good_files)
    for f = 0L, n_good_files - 1L do good_filenames[f] = good_files[f].l1_filename

    ucomp_average_l1_files, good_filenames, $
                            min_average_files=run->line(wave_region, 'gbu_min_files_for_stddev_diff'), $
                            logger_name=run.logger_name, $
                            mean_averaged_data=mean_data, $
                            median_averaged_data=median_data, $
                            sigma_data=sigma_data, $
                            run=run

    if (n_elements(mean_data) eq 0L) then begin
      mg_log, 'no average produced in %s nm files in %s', $
              wave_region, program_names[program_number], $
              name=run.logger_name, /info
      continue
    endif

    dims = size(mean_data, /dimensions)
    mask = ucomp_annulus(1.1 * median_radius, 1.5 * median_radius, dimensions=dims)
    mask *= ucomp_post_mask(dims, median_post_angle, post_width=60.0)

    ; for *every* file, compute its number of standard deviations from the median
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
          if (n_nonzero gt 0L) then begin
            diff = abs(ext_data[*, *, p, w] - median_data[*, *, p, w]) / sigma_data[*, *, p, w]
            sigma[p, w] = median(diff[nonzero_indices])
          endif
        endfor
      endfor

      for w = 0L, dims[3] - 1L do begin
        mg_log, 'sigma @ %0.3f nm: %s', $
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
