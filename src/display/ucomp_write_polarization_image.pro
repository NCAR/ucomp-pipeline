; docformat = 'rst'

pro ucomp_write_polarization_image, filename, $
                                    file, $
                                    integrated_intensity, $
                                    enhanced_intensity, $
                                    integrated_q, $
                                    integrated_u, $
                                    integrated_linpol, $
                                    azimuth, $
                                    radial_azimuth, $
                                    reduce_factor=reduce_factor, $
                                    run=run
  compile_opt strictarr

  dims = size(integrated_intensity, /dimensions)
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
      integrated_intensity[outside_mask_indices] = !values.f_nan
      enhanced_intensity[outside_mask_indices]   = !values.f_nan
      integrated_q[outside_mask_indices]         = !values.f_nan
      integrated_u[outside_mask_indices]         = !values.f_nan
      integrated_linpol[outside_mask_indices]    = !values.f_nan
      azimuth[outside_mask_indices]              = !values.f_nan
      radial_azimuth[outside_mask_indices]       = !values.f_nan
    endif
  endif

  integrated_intensity_display = ucomp_display_image(file.wave_region, integrated_intensity, $
                                                     type='intensity', $
                                                     name='Integrated intensity', $
                                                     reduce_factor=reduce_factor, $
                                                     datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                                     run=run)
  enhanced_intensity_display = ucomp_display_image(file.wave_region, enhanced_intensity, $
                                                   type='enhanced_intensity', $
                                                   name='Enhanced intensity', $
                                                   reduce_factor=reduce_factor, $
                                                   datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                                   run=run)
  integrated_q_display = ucomp_display_image(file.wave_region, integrated_q, $
                                             type='quv', $
                                             name='Integrated Q', $
                                             reduce_factor=reduce_factor, $
                                             datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                             run=run)
  integrated_u_display = ucomp_display_image(file.wave_region, integrated_u, $
                                             type='quv', $
                                             name='Integrated U', $
                                             reduce_factor=reduce_factor, $
                                             datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                             run=run)
  integrated_linpol_display = ucomp_display_image(file.wave_region, integrated_linpol, $
                                                  type='linpol', $
                                                  name='Integrated log(L)', $
                                                  reduce_factor=reduce_factor, $
                                                  datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                                  run=run)
  azimuth_display = ucomp_display_image(file.wave_region, azimuth, $
                                        type='azimuth', $
                                        name='Azimuth', $
                                        reduce_factor=reduce_factor, $
                                        datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                        run=run)
  radial_azimuth_display = ucomp_display_image(file.wave_region, radial_azimuth, $
                                               type='radial_azimuth', $
                                               name='Radial azimuth', $
                                               reduce_factor=reduce_factor, $
                                               datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                               run=run)

  display_image = bytarr(3, 3 * nx, 3 * ny)

  display_image[0,      0, 2 * ny] = integrated_intensity_display
  display_image[0,     nx, 2 * ny] = integrated_q_display
  display_image[0, 2 * nx, 2 * ny] = azimuth_display
  display_image[0,      0,     ny] = enhanced_intensity_display
  display_image[0,     nx,     ny] = integrated_u_display
  display_image[0, 2 * nx,     ny] = radial_azimuth_display
  display_image[0,     nx,      0] = integrated_linpol_display

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  write_png, filename, display_image
  mg_log, 'wrote polarization PNG', name=run.logger_name, /debug

  integrated_linpol_display = ucomp_display_image(file.wave_region, integrated_linpol, $
                                                  type='linpol', $
                                                  name='Integrated log(L)', $
                                                  reduce_factor=1, $
                                                  datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                                  run=run)
  linpol_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.linpol.png")')
  linpol_filename = filepath(linpol_basename, root=l2_dir)
  write_png, linpol_filename, integrated_linpol_display
  mg_log, 'wrote linear polarization PNG', name=run.logger_name, /debug

  radial_azimuth_display = ucomp_display_image(file.wave_region, radial_azimuth, $
                                               type='radial_azimuth', $
                                               name='Radial azimuth', $
                                               reduce_factor=1, $
                                               datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                               run=run)
  radial_azimuth_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.radazi.png")')
  radial_azimuth_filename = filepath(radial_azimuth_basename, root=l2_dir)
  write_png, radial_azimuth_filename, radial_azimuth_display
  mg_log, 'wrote radial azimuth PNG', name=run.logger_name, /debug
end
