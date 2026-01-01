; docformat = 'rst'

;+
; Produce a quicklook for a given L0 file.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_quicklook, file, run=run
  compile_opt strictarr

  ; TODO: remove when implemented
  mg_log, 'not implemented', name=run.logger_name, /info
  goto, done

  datetime = strmid(file_basename(file.raw_filename), 0, 15)
  run.datetime = datetime

  ucomp_read_raw_data, file.raw_filename, $
                       primary_header=primary_header, $
                       ext_data=data, $
                       ext_headers=headers, $
                       repair_routine=run->epoch('raw_data_repair_routine'), $
                       badframes=run.badframes, $
                       metadata_fixes=run.metadata_fixes

  ; find only center wavelength in each camera
  rcam_indices = where(abs(file.wavelengths - file.center_wavelength) lt 0.001 $
                         and file.onband_indices eq 0, $
                       n_rcam)
  rcam_image = ext_data[*, *, *, 0, rcam_indices[0]]

  tcam_indices = where(abs(file.wavelengths - file.center_wavelength) lt 0.001 $
                         and file.onband_indices eq 1, $
                       n_tcam)
  tcam_image = ext_data[*, *, *, 1, tcam_indices[0]]

  ; dark correct
  rcam_dark = 560.0   ; TODO: fix this
  rcam_dark = 560.0   ; TODO: fix this
  rcam_image -= rcam_dark
  tcam_image -= tcam_dark

  ; gain correct
  rcam_flat = 840.0   ; TODO: fix this
  tcam_flat = 840.0   ; TODO: fix this
  rcam_image /= rcam_flat
  tcam_image /= tcam_flat
  opal_radiance = ucomp_opal_radiance(file.wave_region, run=run)
  rcam_image *= opal_radiance
  tcam_image *= opal_radiance

  ; demodulation
  wave_region_index = where(file.wave_region eq run.all_wave_regions, n_found)
  dmatrix_coefficients = run->get_dmatrix_coefficients(datetime=datetime)
  dmatrix = ucomp_get_dmatrix(dmatrix_coefficients, $
                              file.tu_mod, $
                              wave_region_index[0])
  rcam_image = ucomp_quick_demodulation(dmatrix, rcam_image)
  tcam_image = ucomp_quick_demodulation(dmatrix, tcam_image)

  ; display intensity

  done:
  if (obj_valid(headers)) then obj_destroy, headers

  mg_log, 'done', name=run.logger, /debug
end
