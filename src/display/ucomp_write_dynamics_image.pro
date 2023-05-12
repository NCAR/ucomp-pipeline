; docformat = 'rst'

pro ucomp_write_dynamics_image, filename, $
                                file, $
                                peak_intensity, $
                                enhanced_intensity, $
                                doppler_shift, $
                                line_width, $
                                reduce_factor=reduce_factor, $
                                run=run
  compile_opt strictarr

  dims = size(peak_intensity, /dimensions)
  if (n_elements(reduce_factor) gt 0L) then dims /= reduce_factor
  nx = dims[0]
  ny = dims[1]

  if (run->config('display/mask_l2')) then begin
    ; mask outputs
    field_mask = ucomp_field_mask(nx, ny, run->epoch('field_radius'))
    mask = field_mask

    occulter_mask = ucomp_occulter_mask(nx, ny, file.occulter_radius)
    mask and= occulter_mask

    rcam = file.rcam_geometry
    tcam = file.tcam_geometry

    post_angle = (rcam.post_angle + tcam.post_angle) / 2.0
    post_mask = ucomp_post_mask(dims[0], dims[1], post_angle)
    mask and= post_mask

    offsensor_mask = ucomp_offsensor_mask(dims[0], dims[1], file.p_angle)
    mask and= offsensor_mask

    ; TODO: should we do this intensity mask? what should the threshold be?
    intensity_threshold_mask = peak_intensity gt 0.1
    mask and= intensity_threshold_mask

    outside_mask_indices = where(mask eq 0, n_outside_mask)

    if (n_outside_mask gt 0L) then begin
      peak_intensity[outside_mask_indices]     = !values.f_nan
      enhanced_intensity[outside_mask_indices] = !values.f_nan
      doppler_shift[outside_mask_indices]      = !values.f_nan
      line_width[outside_mask_indices]         = !values.f_nan
    endif
  endif

  peak_intensity_display = ucomp_display_image(file.wave_region, peak_intensity, $
                                               type='intensity', $
                                               name='Peak intensity', $
                                               reduce_factor=reduce_factor, $
                                               datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                               run=run)
  enhanced_peak_intensity_display = ucomp_display_image(file.wave_region, enhanced_intensity, $
                                                        type='enhanced_intensity', $
                                                        name='Enhanced peak intensity', $
                                                        reduce_factor=reduce_factor, $
                                                        datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                                        run=run)
  doppler_display = ucomp_display_image(file.wave_region, doppler_shift, $
                                        type='doppler', $
                                        name='Doppler velocity', $
                                        reduce_factor=reduce_factor, $
                                        datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                        run=run)
  line_width_display = ucomp_display_image(file.wave_region, line_width, $
                                           type='line_width', $
                                           name='Line width', $
                                           reduce_factor=reduce_factor, $
                                           datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                           run=run)

  display_image = bytarr(3, 2 * nx, 2 * ny)

  display_image[0,  0, ny] = peak_intensity_display
  display_image[0, nx, ny] = doppler_display
  display_image[0,  0,  0] = enhanced_peak_intensity_display
  display_image[0, nx,  0] = line_width_display

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  write_png, filename, display_image
  mg_log, 'wrote dynamics PNG', name=run.logger_name, /debug

  peak_intensity_image = ucomp_display_image(file.wave_region, peak_intensity, $
                                             type='intensity', $
                                             name='Peak intensity', $
                                             reduce_factor=1, $
                                             datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                             run=run)
  peak_intensity_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.peakint.png")')
  peak_intensity_filename = filepath(peak_intensity_basename, root=l2_dir)
  write_png, peak_intensity_filename, peak_intensity_image
  mg_log, 'wrote peak intensity PNG', name=run.logger_name, /debug

  enhanced_peak_intensity_image = ucomp_display_image(file.wave_region, enhanced_intensity, $
                                                      type='enhanced_intensity', $
                                                      name='Enhanced peak intensity', $
                                                      reduce_factor=1, $
                                                      datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                                      run=run)
  enhanced_peak_intensity_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.enhanced-peakint.png")')
  enhanced_peak_intensity_filename = filepath(enhanced_peak_intensity_basename, root=l2_dir)
  write_png, enhanced_peak_intensity_filename, enhanced_peak_intensity_image
  mg_log, 'wrote enhanced peak intensity PNG', name=run.logger_name, /debug

  doppler_image = ucomp_display_image(file.wave_region, doppler_shift, $
                                      type='doppler', $
                                      name='Doppler velocity', $
                                      reduce_factor=1, $
                                      datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                      run=run)
  doppler_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.velocity.png")')
  doppler_filename = filepath(doppler_basename, root=l2_dir)
  write_png, doppler_filename, doppler_image
  mg_log, 'wrote doppler PNG', name=run.logger_name, /debug

  line_width_image = ucomp_display_image(file.wave_region, line_width, $
                                         type='line_width', $
                                         name='Line width', $
                                         reduce_factor=1, $
                                         datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                         run=run)
  line_width_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.linewidth.png")')
  line_width_filename = filepath(line_width_basename, root=l2_dir)
  write_png, line_width_filename, line_width_image
  mg_log, 'wrote line width PNG', name=run.logger_name, /debug
end
