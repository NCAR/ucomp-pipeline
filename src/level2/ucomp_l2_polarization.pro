; docformat = 'rst'
 
;+
; Produce the polarization images:
;
; - average intensity
; - enhanced intensity
; - average Q
; - average U
; - average L
; - azimuth
; - radial azimuth
;
; :Params:
;   file : in, required, type=object
;     UCoMP file object
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_l2_polarization, file, run=run
  compile_opt strictarr

  ; check GBU
  if (~file.ok || file.gbu ne 0L) then begin
    mg_log, 'poor quality, skipping %s', file.l1_basename, $
            name=run.logger_name, /warn
    goto, done
  endif

  run.datetime = strmid(file_basename(file.raw_filename), 0, 15)

  ; read level 1 file
  l1_filename = filepath(file.l1_basename, $
                         subdir=[run.date, 'level1'], $
                         root=run->config('processing/basedir'))
  if (~file_test(l1_filename, /regular)) then begin
    mg_log, '%d does not exist, skipping', file.l1_basename, $
            name=run.logger_name, /warn
    goto, done
  endif

  ucomp_read_l1_data, l1_filename, $
                      primary_header=primary_header, $
                      ext_data=ext_data, $
                      ext_headers=ext_headers, $
                      n_extensions=n_extensions

  ; find center wavelength
  center_indices = file->get_center_wavelength_indices()
  if (n_elements(center_indices) gt 1L) then begin
    mg_log, 'multiple center wavelengths in level 1 file: %s', $
            strjoin(strtrim(center_indices, 2), ', '), $
            name=run.logger_name, $
            /error
    goto, done
  endif
  center_index = center_indices[0]
  wavelengths = file.wavelengths

  center_indices = [center_index - 1, center_index, center_index + 1]

  center_intensity = reform(ext_data[*, *, 0, center_index - 1:center_index + 1])
  center_q         = reform(ext_data[*, *, 1, center_index - 1:center_index + 1])
  center_u         = reform(ext_data[*, *, 2, center_index - 1:center_index + 1])

  average_intensity = total(center_intensity, 3) / 2.0
  average_q         = total(center_q, 3) / 2.0
  average_u         = total(center_u, 3) / 2.0

  average_linpol = sqrt(average_q^2 + average_u^2)

  enhanced_intensity = ucomp_enhanced_intensity(average_intensity, $
                                                primary_header, $
                                                run->epoch('field_radius'))

  azimuth = ucomp_azimuth(average_q, average_u, radial_azimuth=radial_azimuth)

  ; write polarization file: YYYYMMDD.HHMMSS.ucomp.WWWW.polarization.fts
  polarization_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.polarization.fts")')
  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif
  polarization_filename = filepath(polarization_basename, root=l2_dir)

  mg_log, 'writing %s', polarization_basename, name=run.logger_name, /info

  fits_open, polarization_filename, fcb, /write
  ucomp_fits_write, fcb, 0.0, primary_header, /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write intensity
  ucomp_fits_write, fcb, average_intensity, ext_headers[0], $
                    extname='Average intensity', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write enhanced intensity
  ucomp_fits_write, fcb, enhanced_intensity, ext_headers[0], $
                    extname='Enhanced average intensity', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write Q
  ucomp_fits_write, fcb, average_q, ext_headers[0], $
                    extname='Average Q', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write U
  ucomp_fits_write, fcb, average_u, ext_headers[0], $
                    extname='Average U', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write linear polarization
  ucomp_fits_write, fcb, average_linpol, ext_headers[0], $
                    extname='Average L', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write azimuth
  ucomp_fits_write, fcb, azimuth, ext_headers[0], $
                    extname='Azimuth', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write radial azimuth
  ucomp_fits_write, fcb, radial_azimuth, ext_headers[0], $
                    extname='Radial azimuth', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  fits_close, fcb

  done:
end
