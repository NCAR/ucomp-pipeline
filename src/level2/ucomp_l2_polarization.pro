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

  center_indices = [center_index - 1, center_index, center_index + 1]

  center_intensity = reform(ext_data[*, *, 0, center_index - 1:center_index + 1])
  center_q         = reform(ext_data[*, *, 1, center_index - 1:center_index + 1])
  center_u         = reform(ext_data[*, *, 2, center_index - 1:center_index + 1])

  average_intensity = total(center_intensity, 3) / 2.0
  average_q         = total(center_q, 3) / 2.0
  average_u         = total(center_u, 3) / 2.0

  average_linpol = sqrt(average_q^2 + average_u^2)

  d_lambda = wavelengths[center_index] - wavelengths[center_index - 1]
  ucomp_analytic_gauss_fit, center_intensity[*, *, 0], $
                            center_intensity[*, *, 1], $
                            center_intensity[*, *, 2], $
                            d_lambda, $
                            doppler_shift=doppler_shift, $
                            line_width=line_width, $
                            peak_intensity=peak_intensity

  enhanced_intensity = ucomp_enhanced_intensity(average_intensity, $
                                                line_width, $
                                                doppler_shift, $
                                                primary_header, $
                                                run->epoch('field_radius'), $
                                                radius=run->line(file.wave_region, 'enhanced_intensity_radius'), $
                                                amount=run->line(file.wave_region, 'enhanced_intensity_amount'))

  azimuth = ucomp_azimuth(average_q, average_u, radial_azimuth=radial_azimuth)

  ; mask outputs
  dims = size(average_intensity, /dimensions)
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
    average_intensity[outside_mask_indices]  = !values.f_nan
    average_q[outside_mask_indices]          = !values.f_nan
    average_u[outside_mask_indices]          = !values.f_nan
    average_linpol[outside_mask_indices]     = !values.f_nan
    enhanced_intensity[outside_mask_indices] = !values.f_nan
    azimuth[outside_mask_indices]            = !values.f_nan
    radial_azimuth[outside_mask_indices]     = !values.f_nan
  endif

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  ; write polarization file: YYYYMMDD.HHMMSS.ucomp.WWWW.polarization.fts
  polarization_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.polarization.fts")')
  polarization_filename = filepath(polarization_basename, root=l2_dir)

  mg_log, 'writing %s', polarization_basename, name=run.logger_name, /info

  ; promote header
  ucomp_addpar, primary_header, 'LEVEL', 'L2', comment='level 2 calibrated'

  fits_open, polarization_filename, fcb, /write
  ucomp_fits_write, fcb, 0.0, primary_header, /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write intensity
  ucomp_fits_write, fcb, float(average_intensity), ext_headers[0], $
                    extname='Average intensity', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write enhanced intensity
  ucomp_fits_write, fcb, float(enhanced_intensity), ext_headers[0], $
                    extname='Enhanced average intensity', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write Q
  ucomp_fits_write, fcb, float(average_q), ext_headers[0], $
                    extname='Average Q', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write U
  ucomp_fits_write, fcb, float(average_u), ext_headers[0], $
                    extname='Average U', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write linear polarization
  ucomp_fits_write, fcb, float(average_linpol), ext_headers[0], $
                    extname='Average log(L)', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write azimuth
  ucomp_fits_write, fcb, float(azimuth), ext_headers[0], $
                    extname='Azimuth', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write radial azimuth
  ucomp_fits_write, fcb, float(radial_azimuth), ext_headers[0], $
                    extname='Radial azimuth', /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  fits_close, fcb


  polarization_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.polarization.png")')
  polarization_filename = filepath(polarization_basename, root=l2_dir)

  ucomp_write_polarization_image, polarization_filename, $
                                  file, $
                                  average_intensity, $
                                  enhanced_intensity, $
                                  average_q, $
                                  average_u, $
                                  average_linpol, $
                                  azimuth, $
                                  radial_azimuth, $
                                  reduce_factor=4L, $
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

ucomp_l2_polarization, file, run=run

obj_destroy, run

end