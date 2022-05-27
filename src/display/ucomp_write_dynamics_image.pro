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

  display_image = bytarr(3, 2 * dims[0], 2 * dims[1])

  display_image[0, 0, ny] = ucomp_display_image(file, peak_intensity, $
                                                type='intensity', $
                                                name='Peak intensity', $
                                                reduce_factor=reduce_factor, $
                                                run=run)
  display_image[0, 0, 0] = ucomp_display_image(file, enhanced_intensity, $
                                               type='intensity', $
                                               name='Enhanced peak intensity', $
                                               reduce_factor=reduce_factor, $
                                               run=run)
  display_image[0, nx, ny] = ucomp_display_image(file, doppler_shift, $
                                                 type='doppler', $
                                                 name='Doppler velocity', $
                                                 reduce_factor=reduce_factor, $
                                                 run=run)
  display_image[0, nx, 0] = ucomp_display_image(file, line_width, $
                                                type='line_width', $
                                                name='Line width', $
                                                reduce_factor=reduce_factor, $
                                                run=run)

  write_png, filename, display_image
end

