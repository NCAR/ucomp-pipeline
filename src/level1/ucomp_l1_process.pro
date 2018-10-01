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

  mg_log, 'L1 processing for %s nm...', wave_type, name='ucomp', /info

  run->getProperty, files=files, wave_type=wave_type, count=n_files
  n_digits = floor(alog10(n_files)) + 1L
  for f = 0L, n_files - 1L do begin
    mg_log, mg_format('%*d/%d @ %s: %s', n_digits, /simple), $
            f + 1, n_files, wave_type, file_basename(file.raw_filename), $
            name='ucomp', /info
    ucomp_l1_process_file, files[f], run=run
  endfor
end
