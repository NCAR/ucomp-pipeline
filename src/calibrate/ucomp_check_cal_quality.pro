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
    run.datetime = strmid(file_basename(file.raw_filename), 0, 15)

    ucomp_read_raw_data, file.raw_filename, $
                         primary_header=primary_header, $
                         ext_data=ext_data, $
                         ext_headers=ext_headers, $
                         repair_routine=run->epoch('raw_data_repair_routine'), $
                         badframes=run.badframes, $
                         metadata_fixes=run.metadata_fixes, $
                         all_zero=all_zero, $
                         use_occulter_id=run->epoch('use_occulter_id'), $
                         occulter_id=run->epoch('occulter_id'), $
                         logger=run.logger_name
    file.all_zero = all_zero

    quality_conditions = ucomp_cal_quality_conditions(file.wave_region, run=run)
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
    if (file.quality_bitmask eq 0) then begin
      mg_log, '%s quality: GOOD', $
              file_basename(file.raw_filename), $
              name=run.logger_name, /debug
    endif else begin
      bad_conditions = ucomp_list_conditions(file.quality_bitmask, quality_conditions)
      mg_log, '%s failed quality: %s', $
              file_basename(file.raw_filename), $
              bad_conditions, $
              name=run.logger_name, /warn
    endelse
  endfor

  !null = where(quality_bitmasks eq 0UL, n_ok_files)
  mg_log, '%d %s files passed quality', n_ok_files, type, name=run.logger_name, /info

  done:
end
