; docformat = 'rst'

;+
; Do the L0 -> L1 processing for a specific wave type.
;
; :Params:
;   wave_region : in, required, type=string
;     wave type to be processed
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_process, wave_region, run=run
  compile_opt strictarr

  mg_log, 'L1 processing for %s nm...', wave_region, name=run.logger_name, /info

  files = run->get_files(data_type='sci', wave_region=wave_region, count=n_files)
  if (n_files eq 0L) then begin
    mg_log, 'no files @ %s nm', wave_region, name=run.logger_name, /debug
    goto, done
  endif

  n_digits = floor(alog10(n_files)) + 1L

  t0 = systime(/seconds)
  for f = 0L, n_files - 1L do begin
    mg_log, mg_format('%*d/%d @ %s: %s', n_digits, /simple), $
            f + 1, n_files, wave_region, file_basename(files[f].raw_filename), $
            name=run.logger_name, /info
    ucomp_l1_process_file, files[f], run=run
  endfor
  t1 = systime(/seconds)

  mg_log, '%0.1f secs/file', (t1 - t0) / n_files, name=run.logger_name, /info

  if (run->config('gbu/perform_check') && run->epoch('perform_gbu_check')) then begin
    ucomp_l1_check_gbu_median_diff, wave_region, run=run
  endif else begin
    mg_log, 'skipping GBU check', name=run.logger_name, /debug
  endelse

  done:
end
