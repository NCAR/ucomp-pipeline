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

  ; find matching 1074 + 1079 pairs of files in the synoptic program that are
  ; within a threshold time (10 minutes?)

  synoptic_1074_files = run->get_files(wave_region='1074', $
                                       program='synoptic', $
                                       count=n_1074_files)
  synoptic_1079_files = run->get_files(wave_region='1079', $
                                       program='synoptic', $
                                       count=n_1079_files)

  if (n_1074_files eq 0L || n_1079_files eq 0L) then begin
    mg_log, 'unable to produce density with %d 1074 nm files and %d 1079 nm, files', $
            n_1074_files, n_1079_files, name=run.logger_name, /warn
    goto, done
  endif

  ; get times for files
  times_1074 = fltarr(n_1074_files) + !values.f_nan
  for f = 0L, n_1074_files - 1L do begin
    if ((synoptic_1074_files[f]).wrote_l2) then begin
      times_1074[f] = (synoptic_1074_files[f]).obsday_hours
    endif
  endfor

  times_1079 = fltarr(n_1079_files) + !values.f_nan
  for f = 0L, n_1079_files - 1L do begin
    if ((synoptic_1079_files[f]).wrote_l2) then begin
      times_1079[f] = (synoptic_1079_files[f]).obsday_hours
    endif
  endfor

  ; find files within threshold time [sec]
  times_1074 = rebin(reform(times_1074, n_1074_files, 1), n_1074_files, n_1079_files)
  times_1079 = rebin(reform(times_1079, 1, n_1079_files), n_1074_files, n_1079_files)

  diffs = abs(times_1074 - times_1079)

  pair_indices = where(60.0 * 60.0 * diffs lt density_file_time_threshold, n_pairs)
  if (n_pairs gt 0L) then begin
    mg_log, '%d density pairs', n_pairs, name=run.logger_name, /info
  endif else begin
    mg_log, 'no density pairs', name=run.logger_name, /warn
    goto, done
  endelse

  pair_xy = array_indices([n_1074_files, n_1079_files], pair_indices, /dimensions)

  output_basenames = strarr(n_pairs)

  for p = 0L, n_pairs - 1L do begin
    index_1074 = pair_xy[0, p]
    index_1079 = pair_xy[1, p]
    file_1074 = synoptic_1074_files[index_1074]
    file_1079 = synoptic_1079_files[index_1079]
    output_basenames[p] = string(strmid(file_1074.l2_basename, 0, 15), $
                                 strmid(file_1079.l2_basename, 9, 6), $
                                 format='%s-%s.ucomp.1074-1079.density.fts')
    ucomp_compute_density_files, file_1074.l2_basename, $
                                 file_1079.l2_basename, $
                                 output_basenames[p], $
                                 ignore_linewidth=density_ignore_linewidth, $
                                 run=run
  endfor

  if (n_pairs eq 0L) then begin
    mg_log, 'no density files to insert into database', $
            name=run.logger_name, /info
  endif else begin
    ucomp_db_density_insert, output_basenames, run=run
  endelse

  done:
end
