; docformat = 'rst'

;+
; Check quality (process or not) for each file.
;
; :Params:
;   wave_type : in, required, type=string
;     wave type to be processed
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_check_sci_quality, wave_type, run=run
  compile_opt strictarr

  files = run->get_files(data_type='sci', wave_type=wave_type, count=n_files)

  if (n_files eq 0L) then begin
    mg_log, 'no files of %s nm', wave_type, name=run.logger_name, /info
    goto, done
  endif else begin
    mg_log, 'checking %d %s nm files...', n_files, wave_type, $
            name=run.logger_name, /info
  endelse

  for f = 0L, n_files - 1L do begin
    ucomp_read_raw_data, (files[f]).raw_filename, ext_data=ext_data

    ; TODO: check ext_data, set quality_bitmask
    quality_bitmask = 0UL

    files[f].quality_bitmask = quality_bitmask
  endfor

  done:
end
