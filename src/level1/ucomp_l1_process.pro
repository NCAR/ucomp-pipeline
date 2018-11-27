; docformat = 'rst'

;+
; Do the L0 -> L1 processing for a specific wave type.
;
; :Params:
;   wave_type : in, required, type=string
;     wave type to be processed
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_process, wave_type, run=run
  compile_opt strictarr

  mg_log, 'L1 processing for %s nm...', wave_type, name=run.logger_name, /info

  run->getProperty, files=files, wave_type=wave_type, count=n_files
  if (n_files eq 0L) then begin
    mg_log, 'no files @ %s nm', wave_type, name=run.logger_name, /debug
    return
  endif

  n_digits = floor(alog10(n_files)) + 1L

  t0 = systime(/seconds)
  for f = 0L, n_files - 1L do begin
    mg_log, mg_format('%*d/%d @ %s: %s', n_digits, /simple), $
            f + 1, n_files, wave_type, file_basename(files[f].raw_filename), $
            name=run.logger_name, /info
    ucomp_l1_process_file, files[f], run=run
  endfor
  t1 = systime(/seconds)

  mg_log, '%0.1f secs/file', (t1 - t0) / n_files, name=run.logger_name, /info
end
