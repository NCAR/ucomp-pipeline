; docformat = 'rst'

;+
; Produce a dynamics image, containing the following extensions:
;
; - intensity
; - enhanced intensity
; - LOS velocity
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

  ; calculate intensity
  intensity = reform(ext_data[*, *, 0, center_index])

  ; calculate enhanced intensity
  enhanced_intensity = ucomp_enhanced_intensity(intensity, $
                                                primary_header, $
                                                run->epoch('field_radius'), $
                                                status=status, $
                                                error_msg=error_msg)
  if (error_msg ne '') then begin
    mg_log, 'error computing enhanced intensity', name=run.logger_name, /warn
    mg_log, 'status: %d', status, name=run.logger_name, /warn
    mg_log, error_msg, name=run.logger_name, /warn
    goto, done
  endif

  ; TODO: calculate LOS velocity
  ; TODO: calculate line width

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
  ucomp_fits_write, fcb, intensity, ext_headers[center_index], $
                    extname='Intensity', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write enhanced intensity
  ucomp_fits_write, fcb, enhanced_intensity, ext_headers[center_index], $
                    extname='Enhanced intensity', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; TODO: write LOS velocity
  ; TODO: write line width

  fits_close, fcb

  done:
end
