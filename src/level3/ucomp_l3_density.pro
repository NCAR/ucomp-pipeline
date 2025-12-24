; docformat = 'rst'

;+
; Level 3 processing step to compute density files.
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_l3_density, run=run
  compile_opt strictarr

  ; read density configuration parameters
  density_file_time_threshold = run->epoch('density_file_time_threshold')
  density_ignore_linewidth = run->epoch('density_ignore_linewidth')

  all_1074_files = run->get_files(wave_region='1074', count=n_1074_files)
  all_1079_files = run->get_files(wave_region='1079', count=n_1079_files)

  if (n_1074_files eq 0L || n_1079_files eq 0L) then begin
    mg_log, 'unable to produce density with %d 1074 nm files and %d 1079 nm, files', $
            n_1074_files, n_1079_files, name=run.logger_name, /warn
    goto, done
  endif

  ; get times for files
  times_1074 = fltarr(n_1074_files) + !values.f_nan
  good_1074 = bytarr(n_1074_files)
  for f = 0L, n_1074_files - 1L do begin
    if ((all_1074_files[f]).wrote_l2) then begin
      times_1074[f] = (all_1074_files[f]).obsday_hours
      good_1074[f] = (all_1074_files[f]).ok
    endif else good_1074[f] = 0B
  endfor

  good_1074_indices = where(good_1074 eq 1B, n_good_1074_files)
  if (n_good_1074_files eq 0L) then begin
    mg_log, 'no good 1074 nm files, quitting', name=run.logger_name, /info
    goto, done
  endif

  mg_log, '%d good 1074 nm files', n_good_1074_files, name=run.logger_name, /info

  times_1079 = fltarr(n_1079_files) + !values.f_nan
  good_1079 = bytarr(n_1079_files)
  for f = 0L, n_1079_files - 1L do begin
    if ((all_1079_files[f]).wrote_l2) then begin
      times_1079[f] = (all_1079_files[f]).obsday_hours
      good_1079[f] = (all_1079_files[f]).ok
    endif else good_1079[f] = 0B
  endfor

  good_1079_indices = where(good_1079 eq 1B, n_good_1079_files)
  if (n_good_1079_files eq 0L) then begin
    mg_log, 'no good 1079 nm files, quitting', name=run.logger_name, /info
    goto, done
  endif

  mg_log, '%d good 1079 nm files', n_good_1079_files, name=run.logger_name, /info

  good_times_1074 = times_1074[good_1074_indices]
  good_1074_files = all_1074_files[good_1074_indices]
  good_times_1079 = times_1079[good_1079_indices]
  good_1079_files = all_1079_files[good_1079_indices]

  ; - for every good 1079 file:
  ;   - make a density file with the nearest good 1074 file (if within 20 min)
  ;     before the 1079 file
  ;   - make a density file with the nearest good 1074 file (if within 20 min)
  ;     after the 1079 file

  ; find files within threshold time [sec]
  good_times_1074 = rebin(reform(good_times_1074, n_good_1074_files, 1), $
                          n_good_1074_files, n_good_1079_files)
  good_times_1079 = rebin(reform(good_times_1079, 1, n_good_1079_files), $
                          n_good_1074_files, n_good_1079_files)

  diffs = 60.0 * 60.0 * (good_times_1074 - good_times_1079)

  output_basenames = strarr(2L * n_good_1079_files)

  for f = 0L, n_good_1079_files - 1L do begin
    file_1079 = good_1079_files[f]
    mg_log, 'matching for %s...', file_1079.l2_basename, name=run.logger_name, /info

    positive_1074_indices = where(diffs[*, f] gt 0.0, n_positive_1074)
    if (n_positive_1074 gt 0L) then begin
      min_later = min(diffs[positive_1074_indices, f], matching_1074_indices)
      if (min_later lt density_file_time_threshold) then begin
        file_1074 = good_1074_files[positive_1074_indices[matching_1074_indices[0]]]
        mg_log, '%s matches for after...', file_1074.l2_basename, name=run.logger_name, /info
        output_basenames[2 * f] = string(strmid(file_1074.l2_basename, 0, 15), $
                                         strmid(file_1079.l2_basename, 9, 6), $
                                         format='%s-%s.ucomp.1074-1079.density.fts')
        ucomp_compute_density_files, file_1074.l2_basename, $
                                     file_1079.l2_basename, $
                                     output_basenames[2 * f], $
                                     ignore_linewidth=density_ignore_linewidth, $
                                     run=run
      endif else begin
        mg_log, 'closest file after is %0.1f secs (> %0.1f secs)', $
                min_later, density_file_time_threshold, $
                name=run.logger_name, /debug
      endelse
    endif else begin
      mg_log, 'no files after 1079 nm file', name=run.logger_name, /info
    endelse

    negative_1074_indices = where(diffs[*, f] lt 0.0, n_negative_1074)
    if (n_negative_1074 gt 0L) then begin
      min_before = max(diffs[negative_1074_indices, f], matching_1074_indices)
      if (abs(min_before) lt density_file_time_threshold) then begin
        file_1074 = good_1074_files[matching_1074_indices[0]]
        mg_log, '%s matches for before...', file_1074.l2_basename, name=run.logger_name, /info
        output_basenames[2 * f + 1] = string(strmid(file_1074.l2_basename, 0, 15), $
                                            strmid(file_1079.l2_basename, 9, 6), $
                                            format='%s-%s.ucomp.1074-1079.density.fts')
        ucomp_compute_density_files, file_1074.l2_basename, $
                                    file_1079.l2_basename, $
                                    output_basenames[2 * f + 1], $
                                    ignore_linewidth=density_ignore_linewidth, $
                                    run=run
      endif else begin
        mg_log, 'closest file before is %0.1f secs (> %0.1f secs)', $
                abs(min_before), density_file_time_threshold, $
                name=run.logger_name, /debug
      endelse
    endif else begin
      mg_log, 'no files before 1079 nm file', name=run.logger_name, /info
    endelse
  endfor

  ; some output_basenames will be the empty string because the corresponding
  ; 1074 file was too far away from the 1079 file, so find the non-empty ones to
  ; insert
  good_output_indices = where(output_basenames ne '', n_good_outputs)
  if (n_good_outputs eq 0L) then begin
    mg_log, 'no density files to insert into database', $
            name=run.logger_name, /info
  endif else begin
    output_basenames = output_basenames[good_output_indices]
    ucomp_db_density_insert, output_basenames, run=run
  endelse

  done:
end
