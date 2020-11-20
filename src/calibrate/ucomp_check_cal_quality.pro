; docformat = 'rst'

;+
; Check quality (process or not) for each calibration file.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_check_cal_quality, run=run
  compile_opt strictarr

  files = run->get_files(data_type='cal', count=n_files)

  if (n_files eq 0L) then begin
    mg_log, 'no cal files', name=run.logger_name, /info
    goto, done
  endif else begin
    mg_log, 'checking %d cal files...', n_files, $
            name=run.logger_name, /info
  endelse

  for f = 0L, n_files - 1L do begin
    ucomp_read_raw_data, (files[f]).raw_filename, ext_data=ext_data

    ; TODO: check ext_data, set quality_bitmask
    mg_log, 'not implemented', name=run.logger_name, /warn
    quality_bitmask = 0UL

    files[f].quality_bitmask = quality_bitmask
  endfor

  done:
end
