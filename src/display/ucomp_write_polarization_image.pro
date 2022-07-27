; docformat = 'rst'

pro ucomp_write_polarization_image, filename, $
                                    file, $
                                    average_intensity, $
                                    enhanced_intensity, $
                                    average_q, $
                                    average_u, $
                                    average_linpol, $
                                    azimuth, $
                                    radial_azimuth, $
                                    reduce_factor=reduce_factor, $
                                    run=run
  compile_opt strictarr

  dims = size(average_intensity, /dimensions)
  if (n_elements(reduce_factor) gt 0L) then dims /= reduce_factor
  nx = dims[0]
  ny = dims[1]

  average_intensity_display = ucomp_display_image(file, average_intensity, $
                                                  type='intensity', $
                                                  name='Average intensity', $
                                                  reduce_factor=reduce_factor, $
                                                  run=run)
  enhanced_intensity_display = ucomp_display_image(file, enhanced_intensity, $
                                                   type='enhanced_intensity', $
                                                   name='Enhanced intensity', $
                                                   reduce_factor=reduce_factor, $
                                                   run=run)
  average_q_display = ucomp_display_image(file, average_q, $
                                          type='quv', $
                                          name='Average Q', $
                                          reduce_factor=reduce_factor, $
                                          run=run)
  average_u_display = ucomp_display_image(file, average_u, $
                                          type='quv', $
                                          name='Average U', $
                                          reduce_factor=reduce_factor, $
                                          run=run)
  average_linpol_display = ucomp_display_image(file, average_linpol, $
                                               type='linpol', $
                                               name='Average log(L)', $
                                               reduce_factor=reduce_factor, $
                                               run=run)
  azimuth_display = ucomp_display_image(file, azimuth, $
                                        type='azimuth', $
                                        name='Azimuth', $
                                        reduce_factor=reduce_factor, $
                                        run=run)
  radial_azimuth_display = ucomp_display_image(file, radial_azimuth, $
                                               type='radial_azimuth', $
                                               name='Radial azimuth', $
                                               reduce_factor=reduce_factor, $
                                               run=run)

  display_image = bytarr(3, 3 * dims[0], 3 * dims[1])
  display_image[0, 0, 2 * ny] = average_intensity_display
  display_image[0, 0, ny] = enhanced_intensity_display
  display_image[0, nx, 2 * ny] = average_q_display
  display_image[0, nx, ny] = average_u_display
  display_image[0, nx, 0] = average_linpol_display
  display_image[0, 2 * nx, 2 * ny] = azimuth_display
  display_image[0, 2 * nx, ny] = radial_azimuth_display

  write_png, filename, display_image

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  average_linpol_display = ucomp_display_image(file, average_linpol, $
                                               type='linpol', $
                                               name='Average log(L)', $
                                               reduce_factor=1, $
                                               run=run)
  linpol_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.linpol.png")')
  linpol_filename = filepath(linpol_basename, root=l2_dir)
  write_png, linpol_filename, average_linpol_display

  radial_azimuth_display = ucomp_display_image(file, radial_azimuth, $
                                               type='radial_azimuth', $
                                               name='Radial azimuth', $
                                               reduce_factor=1, $
                                               run=run)
  radial_azimuth_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.radazi.png")')
  radial_azimuth_filename = filepath(radial_azimuth_basename, root=l2_dir)
  write_png, radial_azimuth_filename, radial_azimuth_display
end
