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
                                               type='enhanced_intensity', $
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

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  peak_intensity_image = ucomp_display_image(file, peak_intensity, $
                                             type='intensity', $
                                             name='Peak intensity', $
                                             reduce_factor=1, $
                                             run=run)
  peak_intensity_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.peakint.png")')
  peak_intensity_filename = filepath(peak_intensity_basename, root=l2_dir)
  write_png, peak_intensity_filename, peak_intensity_image

  enhanced_peak_intensity_image = ucomp_display_image(file, enhanced_intensity, $
                                                      type='enhanced_intensity', $
                                                      name='Enhanced peak intensity', $
                                                      reduce_factor=1, $
                                                      run=run)
  enhanced_peak_intensity_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.enhanced-peakint.png")')
  enhanced_peak_intensity_filename = filepath(enhanced_peak_intensity_basename, root=l2_dir)
  write_png, enhanced_peak_intensity_filename, enhanced_peak_intensity_image

  doppler_image = ucomp_display_image(file, doppler_shift, $
                                      type='doppler', $
                                      name='Doppler velocity', $
                                      reduce_factor=1, $
                                      run=run)
  doppler_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.velocity.png")')
  doppler_filename = filepath(doppler_basename, root=l2_dir)
  write_png, doppler_filename, doppler_image

  line_width_image = ucomp_display_image(file, line_width, $
                                         type='line_width', $
                                         name='Line width', $
                                         reduce_factor=1, $
                                         run=run)
  line_width_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.linewidth.png")')
  line_width_filename = filepath(line_width_basename, root=l2_dir)
  write_png, line_width_filename, line_width_image
end

