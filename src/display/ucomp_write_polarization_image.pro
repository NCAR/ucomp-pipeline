; docformat = 'rst'

;+
; Write a level 2 dynamics display image as a PNG, as well as separate peak
; intensity, enhanced peak intensity, doppler velocity, and line width PNGs.
;
; :Params:
;   output_filename : in, required, type=string
;     full path of output file to write
;   file : in, required, type=object
;     `ucomp_file` object to corresponding level 1 file
;   summed_intensity : in, required, type="fltarr(nx, ny)"
;     summed intensity image
;   enhanced_intensity : in, required, type="fltarr(nx, ny)"
;     enhanced summed intensity image
;   summed_q : in, required, type="fltarr(nx, ny)"
;     summed Q image
;   summed_u : in, required, type="fltarr(nx, ny)"
;     summed U image
;   summed_linpol : in, required, type="fltarr(nx, ny)"
;     summed linear polarization image
;   azimuth : in, required, type="fltarr(nx, ny)"
;     azimuth image
;   radial_azimuth : in, required, type="fltarr(nx, ny)"
;     radial azimuth image
;
; :Keywords:
;   reduce_factor : in, optional, type=integer, default=1
;     factor to reduce the height and width of the input image dimensions by
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_write_polarization_image, output_filename, $
                                    file, $
                                    summed_intensity, $
                                    enhanced_intensity, $
                                    summed_q, $
                                    summed_u, $
                                    summed_linpol, $
                                    azimuth, $
                                    radial_azimuth, $
                                    reduce_factor=reduce_factor, $
                                    run=run
  compile_opt strictarr

  dims = size(summed_intensity, /dimensions)

  if (run->config('display/mask_l2')) then begin
    ; mask outputs
    rcam = file.rcam_geometry
    tcam = file.tcam_geometry
    mask = ucomp_mask(dims[0:1], $
                      field_radius=run->epoch('field_radius'), $
                      occulter_radius=file.occulter_radius, $
                      post_angle=(rcam.post_angle + tcam.post_angle) / 2.0, $
                      p_angle=file.p_angle)

    ; TODO: what should the threshold be?
    if (run->config('polarization/mask_noise')) then begin
      intensity_threshold_mask = summed_intensity gt 0.1
      mask and= intensity_threshold_mask
    endif

    outside_mask_indices = where(mask eq 0, n_outside_mask)

    if (n_outside_mask gt 0L) then begin
      summed_intensity[outside_mask_indices]   = !values.f_nan
      enhanced_intensity[outside_mask_indices] = !values.f_nan
      summed_q[outside_mask_indices]           = !values.f_nan
      summed_u[outside_mask_indices]           = !values.f_nan
      summed_linpol[outside_mask_indices]      = !values.f_nan
      azimuth[outside_mask_indices]            = !values.f_nan
      radial_azimuth[outside_mask_indices]     = !values.f_nan
    endif
  endif

  if (n_elements(reduce_factor) gt 0L) then dims /= reduce_factor
  nx = dims[0]
  ny = dims[1]

  summed_q_i = summed_q / summed_intensity
  summed_u_i = summed_u / summed_intensity
  summed_linpol_i = summed_linpol / summed_intensity

  summed_intensity_display = ucomp_display_image(file.wave_region, summed_intensity, $
                                                 type='intensity', $
                                                 name='Summed intensity', $
                                                 reduce_factor=reduce_factor, $
                                                 datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                                 run=run)
  enhanced_intensity_display = ucomp_display_image(file.wave_region, enhanced_intensity, $
                                                   type='enhanced_intensity', $
                                                   name='Enhanced intensity', $
                                                   reduce_factor=reduce_factor, $
                                                   /no_wave_region_annotation, $
                                                   run=run)
  summed_q_display = ucomp_display_image(file.wave_region, summed_q_i, $
                                         type='quv_i', $
                                         name='Summed Q / I', $
                                         reduce_factor=reduce_factor, $
                                         /no_wave_region_annotation, $
                                         run=run)
  summed_u_display = ucomp_display_image(file.wave_region, summed_u_i, $
                                         type='quv_i', $
                                         name='Summed U / I', $
                                         reduce_factor=reduce_factor, $
                                         /no_wave_region_annotation, $
                                         run=run)
  summed_linpol_display = ucomp_display_image(file.wave_region, summed_linpol_i, $
                                              type='linpol', $
                                              name='Summed log!I10!N(L / I)', $
                                              reduce_factor=reduce_factor, $
                                              /no_wave_region_annotation, $
                                              run=run)
  azimuth_display = ucomp_display_image(file.wave_region, azimuth, $
                                        type='azimuth', $
                                        name='Azimuth', $
                                        reduce_factor=reduce_factor, $
                                        /no_wave_region_annotation, $
                                        run=run)
  radial_azimuth_display = ucomp_display_image(file.wave_region, radial_azimuth, $
                                               type='radial_azimuth', $
                                               name='Radial azimuth', $
                                               reduce_factor=reduce_factor, $
                                               /no_wave_region_annotation, $
                                               run=run)

  display_image = bytarr(3, 3 * nx, 3 * ny)

  display_image[0,      0, 2 * ny] = summed_intensity_display
  display_image[0,     nx, 2 * ny] = summed_q_display
  display_image[0, 2 * nx, 2 * ny] = azimuth_display
  display_image[0,      0,     ny] = enhanced_intensity_display
  display_image[0,     nx,     ny] = summed_u_display
  display_image[0, 2 * nx,     ny] = radial_azimuth_display
  display_image[0,     nx,      0] = summed_linpol_display

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  write_png, output_filename, display_image
  mg_log, 'wrote polarization PNG', name=run.logger_name, /debug

  summed_linpol_i_display = ucomp_display_image(file.wave_region, summed_linpol_i, $
                                                type='linpol', $
                                                name='Summed log!I10!N(L)', $
                                                reduce_factor=1, $
                                                datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                                run=run)
  linpol_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.linear_polarization.png")')
  linpol_filename = filepath(linpol_basename, root=l2_dir)
  write_png, linpol_filename, summed_linpol_i_display
  mg_log, 'wrote linear polarization PNG', name=run.logger_name, /debug

  azimuth_display = ucomp_display_image(file.wave_region, azimuth, $
                                        type='azimuth', $
                                        name='Azimuth', $
                                        reduce_factor=1, $
                                        datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                        run=run)
  azimuth_basename = string(strmid(file.l1_basename, 0, 15), $
                            file.wave_region, $
                            format='(%"%s.ucomp.%s.l2.azimuth.png")')
  azimuth_filename = filepath(azimuth_basename, root=l2_dir)
  write_png, azimuth_filename, azimuth_display
  mg_log, 'wrote azimuth PNG', name=run.logger_name, /debug

  radial_azimuth_display = ucomp_display_image(file.wave_region, radial_azimuth, $
                                               type='radial_azimuth', $
                                               name='Radial azimuth', $
                                               reduce_factor=1, $
                                               datetime=strmid(file_basename(file.raw_filename), 0, 15), $
                                               run=run)
  radial_azimuth_basename = string(strmid(file.l1_basename, 0, 15), $
                                 file.wave_region, $
                                 format='(%"%s.ucomp.%s.l2.radial_azimuth.png")')
  radial_azimuth_filename = filepath(radial_azimuth_basename, root=l2_dir)
  write_png, radial_azimuth_filename, radial_azimuth_display
  mg_log, 'wrote radial azimuth PNG', name=run.logger_name, /debug
end
