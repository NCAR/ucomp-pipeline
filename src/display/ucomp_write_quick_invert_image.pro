; docformat = 'rst'

pro ucomp_write_quick_invert_image, filename, $
                                    integrated_intensity, $
                                    integrated_q_i, $
                                    integrated_u_i, $
                                    integrated_linpol_i, $
                                    azimuth, $
                                    radial_azimuth, $
                                    doppler_shift, $
                                    line_width, $
                                    reduce_factor=reduce_factor, $
                                    wave_region=wave_region, $
                                    run=run
  compile_opt strictarr

  dims = size(integrated_intensity, /dimensions)
  if (n_elements(reduce_factor) gt 0L) then dims /= reduce_factor

  nx = dims[0]
  ny = dims[1]

  integrated_intensity_display = ucomp_display_image(wave_region, integrated_intensity, $
                                                     type='intensity', $
                                                     name='Integrated intensity', $
                                                     reduce_factor=reduce_factor, $
                                                     run=run)

  integrated_q_display = ucomp_display_image(wave_region, integrated_q_i, $
                                             type='quv', $
                                             name='Integrated Q /I', $
                                             reduce_factor=reduce_factor, $
                                             run=run)

  integrated_u_display = ucomp_display_image(wave_region, integrated_u_i, $
                                             type='quv', $
                                             name='Integrated U / I', $
                                             reduce_factor=reduce_factor, $
                                             run=run)

  integrated_linpol_display = ucomp_display_image(wave_region, integrated_linpol_i, $
                                                  type='linpol', $
                                                  name='Integrated L / I', $
                                                  reduce_factor=reduce_factor, $
                                                  run=run)

  azimuth_display = ucomp_display_image(wave_region, azimuth, $
                                        type='azimuth', $
                                        name='Azimuth', $
                                        reduce_factor=reduce_factor, $
                                        run=run)

  radial_azimuth_display = ucomp_display_image(wave_region, radial_azimuth, $
                                               type='radial_azimuth', $
                                               name='Radial azimuth', $
                                               reduce_factor=reduce_factor, $
                                               run=run)

  doppler_shift_display = ucomp_display_image(wave_region, doppler_shift, $
                                              type='doppler', $
                                              name='Radial azimuth', $
                                              reduce_factor=reduce_factor, $
                                              run=run)

  line_width_display = ucomp_display_image(wave_region, line_width, $
                                           type='line_width', $
                                           name='Line width', $
                                           reduce_factor=reduce_factor, $
                                           run=run)

  display_image = bytarr(3, 4 * dims[0], 2 * dims[1])

  display_image[0,      0, ny] = integrated_intensity_display
  display_image[0, 1 * nx, ny] = integrated_q_display
  display_image[0, 2 * nx, ny] = integrated_u_display
  display_image[0, 3 * nx, ny] = integrated_linpol_display
  display_image[0,      0,  0] = azimuth_display
  display_image[0, 1 * nx,  0] = radial_azimuth_display
  display_image[0, 2 * nx,  0] = doppler_shift_display
  display_image[0, 3 * nx,  0] = line_width_display

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  write_png, filename, display_image
  mg_log, 'wrote %s', file_basename(filename), name=run.logger_name, /info
end
