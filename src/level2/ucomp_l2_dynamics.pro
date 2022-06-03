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
    mg_log, '%s does not exist, skipping', file.l1_basename, $
            name=run.logger_name, /warn
    goto, done
  endif

  if (file.n_unique_wavelengths lt 3L) then begin
    mg_log, '%s does not have 3 unique wavelengths, skipping', $
            file.l1_basename, $
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
                                                line_width, $
                                                doppler_shift, $
                                                primary_header, $
                                                run->epoch('field_radius'), $
                                                radius=run->line(file.wave_region, 'enhanced_intensity_radius'), $
                                                amount=run->line(file.wave_region, 'enhanced_intensity_amount'))

  c = 299792.458D

  ; convert Doppler shift to velocity [km/s]
  doppler_shift *= c / mean(wavelengths)
  
  ; convert line width to velocity (km/s)
  line_width *= c / mean(wavelengths)

  ; mask outputs
  dims = size(peak_intensity, /dimensions)
  field_mask = ucomp_field_mask(dims[0], $
                                dims[1], $
                                run->epoch('field_radius'))
  occulter_mask = ucomp_occulter_mask(dims[0], dims[1], file.occulter_radius)
  rcam = file.rcam_geometry
  tcam = file.tcam_geometry
  post_angle = (rcam.post_angle + tcam.post_angle) / 2.0
  post_mask = ucomp_post_mask(dims[0], dims[1], post_angle)
  offsensor_mask = ucomp_offsensor_mask(dims[0], dims[1], file.p_angle)
  ; TODO: should we do this intensity mask? what should the threshold be?
  intensity_threshold_mask = peak_intensity gt 0.1
  mask = field_mask and occulter_mask and post_mask and offsensor_mask and intensity_threshold_mask
  outside_mask_indices = where(mask eq 0, n_outside_mask)

  if (n_outside_mask gt 0L) then begin
    peak_intensity[outside_mask_indices]     = !values.f_nan
    enhanced_intensity[outside_mask_indices] = !values.f_nan
    doppler_shift[outside_mask_indices]      = !values.f_nan
    line_width[outside_mask_indices]         = !values.f_nan
  endif

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  ; write dynamics file: YYYYMMDD.HHMMSS.ucomp.WWWW.dynamics.fts
  dynamics_basename = string(strmid(file.l1_basename, 0, 15), $
                             file.wave_region, $
                             format='(%"%s.ucomp.%s.dynamics.fts")')
  dynamics_filename = filepath(dynamics_basename, root=l2_dir)

  mg_log, 'writing %s', dynamics_basename, name=run.logger_name, /info

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
                                 format='(%"%s.ucomp.%s.dynamics.png")')
  dynamics_filename = filepath(dynamics_basename, root=l2_dir)

  ucomp_write_dynamics_image, dynamics_filename, $
                              file, $
                              peak_intensity, $
                              enhanced_intensity, $
                              doppler_shift, $
                              line_width, $
                              reduce_factor=2L, $
                              run=run

  done:
end


; main-level example program

date = '20220302'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, subdir=['..', '..', 'config'], root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

l0_basename = '20220302.195202.80.ucomp.1074.l0.fts'
l0_filename = filepath(l0_basename, subdir=[date], root=run->config('raw/basedir'))

file = ucomp_file(l0_filename, run=run)
file->update, 'level1'

ucomp_l2_dynamics, file, run=run

obj_destroy, run

end
