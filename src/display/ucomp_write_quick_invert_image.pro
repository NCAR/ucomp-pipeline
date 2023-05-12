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
                                    post_angle=post_angle, $
                                    p_angle=p_angle, $
                                    occulter_radius=occulter_radius, $
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

    occulter_mask = ucomp_occulter_mask(nx, ny], occulter_radius)
    mask and= occulter_mask

    if (n_elements(post_angle) gt 0L) then begin
      post_mask = ucomp_post_mask(nx, ny, post_angle)
      mask and= post_mask
    endif

    offsensor_mask = ucomp_offsensor_mask(nx, ny, p_angle)
    mask and= offsensor_mask

    outside_mask_indices = where(mask eq 0, n_outside_mask)

    if (n_outside_mask gt 0L) then begin
      integrated_intensity[outside_mask_indices] = !values.f_nan
      integrated_q_i[outside_mask_indices]       = !values.f_nan
      integrated_u_i[outside_mask_indices]       = !values.f_nan
      integrated_linpol_i[outside_mask_indices]  = !values.f_nan
      line_width[outside_mask_indices]           = !values.f_nan
      doppler_shift[outside_mask_indices]        = !values.f_nan
      azimuth[outside_mask_indices]              = !values.f_nan
      radial_azimuth[outside_mask_indices]       = !values.f_nan
    endif
  endif

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

  display_image = bytarr(3, 4 * nx, 2 * ny)

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
  mg_log, 'wrote quick invert PNG', name=run.logger_name, /debug
end


; main-level example program
date = '20220310'
wave_region = '1074'
basename = '20220310.ucomp.1074.synoptic.mean.quick_invert.fts'
mode = 'test'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, mode, config_filename)

l2_dirname = filepath('', subdir=[date, 'level2'], root=run->config('processing/basedir'))

filename = filepath(basename, root=l2_dirname)
fits_open, filename, fcb
fits_read, fcb, primary_data, primary_header, exten_no=0
fits_read, fcb, integrated_intensity, exten_no=1
fits_read, fcb, integrated_q_i, exten_no=2
fits_read, fcb, integrated_u_i, exten_no=3
fits_read, fcb, integrated_linpol_i, exten_no=4
fits_read, fcb, azimuth, exten_no=5
fits_read, fcb, radial_azimuth, exten_no=6
fits_read, fcb, doppler_shift, exten_no=7
fits_read, fcb, line_width, exten_no=8
fits_close, fcb

occulter_radius = ucomp_getpar(primary_header, 'RADIUS')
p_angle = ucomp_getpar(primary_header, 'SOLAR_P0')

image_filename = filepath(string(file_basename(basename, '.fts'), $
                                 format='%s.png'), root=l2_dirname)

ucomp_write_quick_invert_image, image_filename, $
                                integrated_intensity, $
                                integrated_q_i, $
                                integrated_u_i, $
                                integrated_linpol_i, $
                                azimuth, $
                                radial_azimuth, $
                                doppler_shift, $
                                line_width, $
                                reduce_factor=4L, $
                                wave_region=wave_region, $
                                p_angle=p_angle, $
                                occulter_radius=occulter_radius, $
                                run=run
obj_destroy, run

end
