; docformat = 'rst'

;+
; Produce a dynamics image, containing the following extensions:
;
; - peak intensity
; - enhanced intensity
; - doppler velocity
; - line width
;
; :Params:
;   file : in, required, type=object
;     UCoMP file object
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_l2_dynamics, file, run=run
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

  ; calculate intensity
  intensity_blue = reform(ext_data[*, *, 0, center_index - 1])
  intensity_center = reform(ext_data[*, *, 0, center_index])
  intensity_red = reform(ext_data[*, *, 0, center_index + 1])
  d_lambda = wavelengths[center_index] - wavelengths[center_index - 1]

  ucomp_analytic_gauss_fit, intensity_blue, $
                            intensity_center, $
                            intensity_red, $
                            d_lambda, $
                            doppler_shift=doppler_shift, $
                            line_width=line_width, $
                            peak_intensity=peak_intensity

  ; calculate enhanced intensity
  enhanced_intensity = ucomp_enhanced_intensity(peak_intensity, $
                                                primary_header, $
                                                run->epoch('field_radius'))

  ; convert Doppler shift to velocity [km/s]
  doppler_shift *= 3.0E5 / mean(wavelengths)
  
  ; convert line width to velocity (km/s)
  line_width *= 3.0E5 / mean(wavelengths)

  ; TODO: fix up primary header and extension headers

  ; write dynamics file: YYYYMMDD.HHMMSS.ucomp.WWWW.dynamics.fts
  dynamics_basename = string(strmid(file.l1_basename, 0, 15), $
                             file.wave_region, $
                             format='(%"%s.ucomp.%s.dynamics.fts")')
  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif
  dynamics_filename = filepath(dynamics_basename, root=l2_dir)

  mg_log, 'writing %s', dynamics_basename, name=run.logger_name, /info

  fits_open, dynamics_filename, fcb, /write
  ucomp_fits_write, fcb, 0.0, primary_header, /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write intensity
  ucomp_fits_write, fcb, peak_intensity, ext_headers[center_index], $
                    extname='Peak intensity', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write enhanced intensity
  ucomp_fits_write, fcb, enhanced_intensity, ext_headers[center_index], $
                    extname='Enhanced peak intensity', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write LOS velocity
  ucomp_fits_write, fcb, doppler_shift, ext_headers[center_index], $
                    extname='Doppler velocity', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write line width
  ucomp_fits_write, fcb, line_width, ext_headers[center_index], $
                    extname='Line width', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  fits_close, fcb

  done:
end
