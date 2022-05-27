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

  display_image = bytarr(3, 3 * dims[0], 3 * dims[1])

  display_image[0, 0, 2 * ny] = ucomp_display_image(file, average_intensity, $
                                                type='intensity', $
                                                name='Average intensity', $
                                                reduce_factor=reduce_factor, $
                                                run=run)
  display_image[0, 0, ny] = ucomp_display_image(file, enhanced_intensity, $
                                               type='intensity', $
                                               name='Enhanced average intensity', $
                                               reduce_factor=reduce_factor, $
                                               run=run)
  display_image[0, nx, 2 * ny] = ucomp_display_image(file, average_q, $
                                                 type='quv', $
                                                 name='Average Q', $
                                                 reduce_factor=reduce_factor, $
                                                 run=run)
  display_image[0, nx, ny] = ucomp_display_image(file, average_u, $
                                                type='quv', $
                                                name='Average U', $
                                                reduce_factor=reduce_factor, $
                                                run=run)
  display_image[0, nx, 0] = ucomp_display_image(file, average_linpol, $
                                                     type='linpol', $
                                                     name='Average log(L)', $
                                                     reduce_factor=reduce_factor, $
                                                     run=run)
  display_image[0, 2 * nx, 2 * ny] = ucomp_display_image(file, azimuth, $
                                                     type='azimuth', $
                                                     name='Azimuth', $
                                                     reduce_factor=reduce_factor, $
                                                     run=run)
  display_image[0, 2 * nx, ny] = ucomp_display_image(file, radial_azimuth, $
                                                    type='radial_azimuth', $
                                                    name='Radial azimuth', $
                                                    reduce_factor=reduce_factor, $
                                                    run=run)

  write_png, filename, display_image
end
