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
    mg_log, 'poor quality for %s', file.l1_basename, $
            name=run.logger_name, /warn
    goto, done
  endif

  run.datetime = strmid(file_basename(file.raw_filename), 0, 15)

  ; read level 1 file
  l1_filename = filepath(file.l1_basename, $
                         subdir=[run.date, 'level1'], $
                         root=run->config('processing/basedir'))
  if (~file_test(l1_filename, /regular)) then begin
    mg_log, '%s does not exist', file.l1_basename, $
            name=run.logger_name, /warn
    goto, done
  endif

  if (file.n_unique_wavelengths lt 3L) then begin
    mg_log, '%s does not have 3 unique wavelengths', $
            file.l1_basename, $
            name=run.logger_name, /warn
    goto, done
  endif

  ucomp_read_l1_data, l1_filename, $
                      primary_header=primary_header, $
                      ext_data=ext_data, $
                      ext_headers=ext_headers, $
                      n_wavelengths=n_wavelengths

  ; find center wavelength
  center_indices = file->get_center_wavelength_indices()
  case 1 of
    n_elements(center_indices) eq 0L: begin
        mg_log, 'no center wavelengths in level 1 file', $
                name=run.logger_name, $
                /error
        goto, done
      end
    n_elements(center_indices) gt 1L: begin
        mg_log, 'multiple center wavelengths in level 1 file: %s', $
                strjoin(strtrim(center_indices, 2), ', '), $
                name=run.logger_name, $
                /error
        goto, done
      end
    (center_indices[0] lt 1L) || (center_indices[0] gt n_wavelengths - 1L): begin
        mg_log, 'not enough wavelengths (center index: %d / %d)', $
                center_indices[0], n_wavelengths, $
                name=run.logger_name, /error
      end
    else:
  endcase
  center_index = center_indices[0]
  wavelengths = file.wavelengths

  ; calculate intensity
  intensity_blue   = reform(ext_data[*, *, 0, center_index - 1])
  intensity_center = reform(ext_data[*, *, 0, center_index])
  intensity_red    = reform(ext_data[*, *, 0, center_index + 1])
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
                                                radius=run->line(file.wave_region, 'enhanced_intensity_radius'), $
                                                amount=run->line(file.wave_region, 'enhanced_intensity_amount'), $
                                                occulter_radius=file.occulter_radius, $
                                                post_angle=file.post_angle, $
                                                field_radius=run->epoch('field_radius'), $
                                                mask=run->config('display/mask_l2'))

  c = 299792.458D

  ; convert Doppler shift to velocity [km/s]
  doppler_shift *= c / mean(wavelengths)

  ; convert line width to velocity (km/s)
  line_width *= c / mean(wavelengths)

  ; mask data on various thresholds
  ; TODO: constants should be retrieved from wave region config file
  if (run->config('dynamics/mask_noise')) then begin
    !null = where(intensity_center gt 0.35 $
                    and intensity_center lt 100.0 $
                    and intensity_blue gt 0.1 $
                    and intensity_red gt 0.1 $
                    and line_width gt 15.0 $
                    and line_width lt 50.0 $
                    and abs(doppler_shift) lt 30.0 $
                    and doppler_shift ne 0.0, $
                  complement=bad_indices, /null)

    peak_intensity[bad_indices]     = !values.f_nan
    enhanced_intensity[bad_indices] = !values.f_nan
    doppler_shift[bad_indices]      = !values.f_nan
    line_width[bad_indices]         = !values.f_nan
  endif

  ; TODO: constants should be retrieved from wave region config file
  valid_indices = where(intensity_center gt 0.9 $
                          and intensity_center lt 100.0 $
                          and intensity_blue gt 0.1 $
                          and intensity_red gt 0.1 $
                          and line_width gt 15.0 $
                          and line_width lt 40.0 $
                          and abs(doppler_shift) lt 5.0 $
                          and doppler_shift ne 0.0, $
                        n_valid_indices)
  if (n_valid_indices gt 0L) then begin
    doppler_shift -= median(doppler_shift[valid_indices])
  endif else begin
    doppler_shift -= median(doppler_shift)
  endelse

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  ; write dynamics file: YYYYMMDD.HHMMSS.ucomp.WWWW.dynamics.fts
  dynamics_filename = filepath(file.dynamics_basename, root=l2_dir)

  mg_log, 'writing %s', file.dynamics_basename, name=run.logger_name, /debug

  ; promote header
  ucomp_addpar, primary_header, 'LEVEL', 'L2', comment='level 2 calibrated'

  fits_open, dynamics_filename, fcb, /write
  ucomp_fits_write, fcb, 0.0, primary_header, /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write intensity
  ucomp_fits_write, fcb, float(peak_intensity), ext_headers[center_index], $
                    extname='Peak intensity', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write enhanced intensity
  ucomp_fits_write, fcb, float(enhanced_intensity), ext_headers[center_index], $
                    extname='Enhanced peak intensity', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write LOS velocity
  ucomp_fits_write, fcb, float(doppler_shift), ext_headers[center_index], $
                    extname='Doppler velocity', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write line width
  ucomp_fits_write, fcb, float(line_width), ext_headers[center_index], $
                    extname='Line width', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  fits_close, fcb

  dynamics_basename = string(strmid(file.l1_basename, 0, 15), $
                             file.wave_region, $
                             format='(%"%s.ucomp.%s.l2.dynamics.png")')
  dynamics_filename = filepath(dynamics_basename, root=l2_dir)

  ucomp_write_dynamics_image, dynamics_filename, $
                              file, $
                              peak_intensity, $
                              enhanced_intensity, $
                              doppler_shift, $
                              line_width, $
                              reduce_factor=2L, $
                              run=run

  file.wrote_dynamics = 1B

  done:
end


; main-level example program

date = '20220901'

config_basename = 'ucomp.publish.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

l0_basename = '20220902.032356.48.ucomp.1074.l0.fts'
l0_filename = filepath(l0_basename, subdir=[date], root=run->config('raw/basedir'))

file = ucomp_file(l0_filename, run=run)
file->update, 'level1'

ucomp_l2_dynamics, file, run=run

obj_destroy, run

end
