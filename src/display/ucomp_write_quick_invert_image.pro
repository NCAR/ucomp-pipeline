; docformat = 'rst'

;+
; Write a level 2 quick invert display image as a PNG.
;
; :Params:
;   output_filename : in, required, type=string
;     full path of output file to write
;   integrated_intensity : in, required, type="fltarr(nx, ny)"
;     integrated intensity image
;   integrated_q_i : in, required, type="fltarr(nx, ny)"
;     integrated Q over I image
;   integrated_u_i: in, required, type="fltarr(nx, ny)"
;     integrated U over I image
;   integrated_linpol_i : in, required, type="fltarr(nx, ny)"
;     integrated linear polarization over I image
;   azimuth : in, required, type="fltarr(nx, ny)"
;     azimuth image
;   radial_azimuth : in, required, type="fltarr(nx, ny)"
;     radial azimuth image
;   doppler_shift : in, required, type="fltarr(nx, ny)"
;     doppler velocity image
;   line_width : in, required, type="fltarr(nx, ny)"
;     line width image
;
; :Keywords:
;   reduce_factor : in, optional, type=integer, default=1
;     factor to reduce the height and width of the input image dimensions by
;   wave_region : in, required, type=string
;     wave region, e.g., "1074"
;   post_angle : in, optional, type=float
;     post angle in degrees from north; if present, mask the post in the output
;     images
;   p_angle : in, optional, type=float
;     p-angle in degrees from north; if present, mask the offsensor pixels in
;     the output images
;   occulter_radius : in, optional, type=float
;     occulter radius in pixels; if present, mask the occulter in the output
;     image
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_write_quick_invert_image, output_filename, $
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

  if (run->config('display/mask_l2')) then begin
    ; mask outputs
    mask = ucomp_mask(dims[0:1], $
                      field_radius=run->epoch('field_radius'), $
                      occulter_radius=occulter_radius, $
                      post_angle=post_angle, $
                      p_angle=p_angle)

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

  if (n_elements(reduce_factor) gt 0L) then dims /= reduce_factor
  nx = dims[0]
  ny = dims[1]

  integrated_intensity_display = ucomp_display_image(wave_region, integrated_intensity, $
                                                     type='intensity', $
                                                     name='Integrated I', $
                                                     reduce_factor=reduce_factor, $
                                                     datetime=run.date, $
                                                     run=run)

  integrated_q_display = ucomp_display_image(wave_region, integrated_q_i, $
                                             type='quv_i', $
                                             name='Integrated Q / I', $
                                             reduce_factor=reduce_factor, $
                                             /no_wave_region_annotation, $
                                             run=run)

  integrated_u_display = ucomp_display_image(wave_region, integrated_u_i, $
                                             type='quv_i', $
                                             name='Integrated U / I', $
                                             reduce_factor=reduce_factor, $
                                             /no_wave_region_annotation, $
                                             run=run)

  integrated_linpol_display = ucomp_display_image(wave_region, integrated_linpol_i, $
                                                  type='linpol', $
                                                  name='Integrated log!E10!N(L / I)', $
                                                  reduce_factor=reduce_factor, $
                                                  /no_wave_region_annotation, $
                                                  run=run)

  doppler_shift_display = ucomp_display_image(wave_region, doppler_shift, $
                                              type='doppler', $
                                              name='LOS velocity', $
                                              reduce_factor=reduce_factor, $
                                              /no_wave_region_annotation, $
                                              run=run)

  line_width_display = ucomp_display_image(wave_region, line_width, $
                                           type='line_width', $
                                           name='Line width', $
                                           reduce_factor=reduce_factor, $
                                           /no_wave_region_annotation, $
                                           run=run)

  azimuth_display = ucomp_display_image(wave_region, azimuth, $
                                        type='azimuth', $
                                        name='Azimuth', $
                                        reduce_factor=reduce_factor, $
                                        /no_wave_region_annotation, $
                                        run=run)

  radial_azimuth_display = ucomp_display_image(wave_region, radial_azimuth, $
                                               type='radial_azimuth', $
                                               name='Radial azimuth', $
                                               reduce_factor=reduce_factor, $
                                               /no_wave_region_annotation, $
                                               run=run)

  display_image = bytarr(3, 4 * nx, 2 * ny)

  display_image[0,      0, ny] = integrated_intensity_display
  display_image[0, 1 * nx, ny] = integrated_q_display
  display_image[0, 2 * nx, ny] = integrated_u_display
  display_image[0, 3 * nx, ny] = integrated_linpol_display
  display_image[0,      0,  0] = doppler_shift_display
  display_image[0, 1 * nx,  0] = line_width_display
  display_image[0, 2 * nx,  0] = azimuth_display
  display_image[0, 3 * nx,  0] = radial_azimuth_display

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  write_png, output_filename, display_image
  mg_log, 'wrote quick invert PNG', name=run.logger_name, /debug

  basename = file_basename(output_filename, '.png')
  base_filename = filepath(basename, root=file_dirname(output_filename))

  integrated_intensity_display = ucomp_display_image(wave_region, $
                                                     integrated_intensity, $
                                                     type='intensity', $
                                                     name='Integrated I', $
                                                     reduce_factor=1, $
                                                     datetime=run.date, $
                                                     run=run)
  integrated_intensity_filename = string(base_filename, format='%s.intensity.png')
  write_png, integrated_intensity_filename, integrated_intensity_display
  mg_log, 'wrote integrated intensity PNG', name=run.logger_name, /debug

  integrated_q_i_display = ucomp_display_image(wave_region, $
                                               integrated_q_i, $
                                               type='quv_i', $
                                               name='Integrated Q / I', $
                                               reduce_factor=1, $
                                               datetime=run.date, $
                                               run=run)
  integrated_q_i_filename = string(base_filename, format='%s.stokesq.png')
  write_png, integrated_q_i_filename, integrated_q_i_display
  mg_log, 'wrote integrated Q / I PNG', name=run.logger_name, /debug

  integrated_u_i_display = ucomp_display_image(wave_region, $
                                               integrated_u_i, $
                                               type='quv_i', $
                                               name='Integrated U / I', $
                                               reduce_factor=1, $
                                               datetime=run.date, $
                                               run=run)
  integrated_u_i_filename = string(base_filename, format='%s.stokesu.png')
  write_png, integrated_u_i_filename, integrated_u_i_display
  mg_log, 'wrote integrated U / I PNG', name=run.logger_name, /debug

  integrated_linpol_i_display = ucomp_display_image(wave_region, $
                                                    integrated_linpol_i, $
                                                    type='linpol', $
                                                    name='Integrated log!I10!N(L / I)', $
                                                    reduce_factor=1, $
                                                    datetime=run.date, $
                                                    run=run)
  linpol_filename = string(base_filename, format='%s.linear_polarization.png')
  write_png, linpol_filename, integrated_linpol_i_display
  mg_log, 'wrote linear polarization PNG', name=run.logger_name, /debug

  doppler_shift_display = ucomp_display_image(wave_region, $
                                              doppler_shift, $
                                              type='doppler', $
                                              name='LOS velocity', $
                                              reduce_factor=1, $
                                              datetime=run.date, $
                                              run=run)
  doppler_shift_filename = string(base_filename, format='%s.velocity.png')
  write_png, doppler_shift_filename, doppler_shift_display
  mg_log, 'wrote LOS velocity PNG', name=run.logger_name, /debug

  line_width_display = ucomp_display_image(wave_region, $
                                           line_width, $
                                           type='line_width', $
                                           name='Line width', $
                                           reduce_factor=1, $
                                           datetime=run.date, $
                                           run=run)
  line_width_filename = string(base_filename, format='%s.line_width.png')
  write_png, line_width_filename, line_width_display
  mg_log, 'wrote line width PNG', name=run.logger_name, /debug

  azimuth_display = ucomp_display_image(wave_region, $
                                        azimuth, $
                                        type='azimuth', $
                                        name='Azimuth', $
                                        reduce_factor=1, $
                                        datetime=run.date, $
                                        run=run)
  azimuth_filename = string(base_filename, format='%s.azimuth.png')
  write_png, azimuth_filename, azimuth_display
  mg_log, 'wrote azimuth PNG', name=run.logger_name, /debug

  radial_azimuth_display = ucomp_display_image(wave_region, $
                                               radial_azimuth, $
                                               type='radial_azimuth', $
                                               name='Radial azimuth', $
                                               reduce_factor=1, $
                                               datetime=run.date, $
                                               run=run)
  radial_azimuth_filename = string(base_filename, format='%s.radial_azimuth.png')
  write_png, radial_azimuth_filename, radial_azimuth_display
  mg_log, 'wrote radial azimuth PNG', name=run.logger_name, /debug
end


; main-level example program
date = '20220901'
wave_region = '1074'
basename = '20220901.ucomp.1074.l2.synoptic.mean.quick_invert.fts'
mode = 'test'

config_basename = 'ucomp.publish.cfg'
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
