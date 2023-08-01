; docformat = 'rst'

;+
; Check quality (process or not) for each calibration file.
;
; :Params:
;   type : in, required, type=string
;     type to check: "dark", "flat", or "cal"
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_check_cal_quality, type, run=run
  compile_opt strictarr

  files = run->get_files(data_type=type, count=n_files)

  if (n_files eq 0L) then begin
    mg_log, 'no %s files', type, name=run.logger_name, /info
    goto, done
  endif else begin
    mg_log, 'checking %d %s files...', n_files, type, name=run.logger_name, /info
  endelse

  quality_bitmasks = ulonarr(n_files)
  for f = 0L, n_files - 1L do begin
    file = files[f]
    quality_conditions = ucomp_cal_quality_conditions(file.wave_region, run=run)
    ucomp_read_raw_data, file.raw_filename, $
                         primary_header=primary_header, $
                         ext_data=ext_data, $
                         ext_headers=ext_headers, $
                         repair_routine=run->epoch('raw_data_repair_routine'), $
                         badframes=run.badframes, $
                         all_zero=all_zero, $
                         logger=run.logger_name
    file.all_zero = all_zero
    for q = 0L, n_elements(quality_conditions) - 1L do begin
      quality = call_function(quality_conditions[q].checker, $
                              file, $
                              primary_header, $
                              ext_data, $
                              ext_headers, $
                              run=run)

      ; check cal data, set quality_bitmask
      quality_bitmasks[f] or= quality_conditions[q].mask * quality
    endfor
    file.quality_bitmask = quality_bitmasks[f]
    mg_log, '%s quality: %d', $
            file_basename(file.raw_filename), $
            file.quality_bitmask, $
            name=run.logger_name, /debug
  endfor

  !null = where(quality_bitmasks eq 0UL, n_ok_files)
  mg_log, '%d %s files passed quality', n_ok_files, type, name=run.logger_name, /info

  done:
end
