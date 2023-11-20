; docformat = 'rst'

;+
; Write the images corresponding to a level 2 file: individual images for each
; quantity as well as a dashboard image of them all.
;
; :Params:
;   quicklook_filename : in, required, type=string
;     full path of output file to write
;   intensity_center : in, required, type="fltarr(nx, ny)"
;     center line intensity
;   enhanced_intensity_center : in, required, type="fltarr(nx, ny)"
;     enhanced center line intensity
;   peak_intensity : in, required, type="fltarr(nx, ny)"
;     peak intensity
;   doppler_shift : in, required, type="fltarr(nx, ny)"
;     doppler velocity image
;   line_width : in, required, type="fltarr(nx, ny)"
;     line width image
;   summed_intensity : in, required, type="fltarr(nx, ny)"
;     summed intensity image
;   summed_q_i : in, required, type="fltarr(nx, ny)"
;     summed Q over I image
;   summed_u_i: in, required, type="fltarr(nx, ny)"
;     summed U over I image
;   summed_linpol_i : in, required, type="fltarr(nx, ny)"
;     summed linear polarization over I image
;   azimuth : in, required, type="fltarr(nx, ny)"
;     azimuth image
;   radial_azimuth : in, required, type="fltarr(nx, ny)"
;     radial azimuth image
;
; :Keywords:
;   write_polarization : in, optional, type=boolean
;     if set, write the polarization images as well as the dynamics images
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
pro ucomp_write_l2_images, quicklook_filename, $

                           ; dynamics images
                           intensity_center, $
                           enhanced_intensity_center, $
                           peak_intensity, $
                           doppler_shift, $
                           line_width, $

                           ; polarization images
                           summed_intensity, $
                           summed_q_i, $
                           summed_u_i, $
                           summed_linpol_i, $
                           azimuth, $
                           radial_azimuth, $

                           write_polarization=write_polarization, $
                           reduce_factor=reduce_factor, $
                           wave_region=wave_region, $
                           post_angle=post_angle, $
                           p_angle=p_angle, $
                           occulter_radius=occulter_radius, $

                           run=run
  compile_opt strictarr

  fill_linpol_images = 1B
  if (fill_linpol_images) then begin
    linpol_nan_indices = where(~finite(summed_linpol_i), /null)
    summed_linpol_i[linpol_nan_indices] = median(summed_linpol_i)
  endif

  dims = size(intensity_center, /dimensions)

  if (run->config('display/mask_l2')) then begin
    ; mask outputs
    mask = ucomp_mask(dims[0:1], $
                      field_radius=run->epoch('field_radius'), $
                      occulter_radius=occulter_radius, $
                      post_angle=post_angle, $
                      p_angle=p_angle)

    outside_mask_indices = where(mask eq 0, n_outside_mask)

    if (n_outside_mask gt 0L) then begin
      intensity_center[outside_mask_indices]          = !values.f_nan
      enhanced_intensity_center[outside_mask_indices] = !values.f_nan
      peak_intensity[outside_mask_indices]            = !values.f_nan
      line_width[outside_mask_indices]                = !values.f_nan
      doppler_shift[outside_mask_indices]             = !values.f_nan

      summed_intensity[outside_mask_indices]          = !values.f_nan
      summed_q_i[outside_mask_indices]                = !values.f_nan
      summed_u_i[outside_mask_indices]                = !values.f_nan
      summed_linpol_i[outside_mask_indices]           = !values.f_nan
      azimuth[outside_mask_indices]                   = !values.f_nan
      radial_azimuth[outside_mask_indices]            = !values.f_nan
    endif
  endif

  if (n_elements(reduce_factor) gt 0L) then dims /= reduce_factor
  nx = dims[0]
  ny = dims[1]

  quicklook_basename = file_basename(quicklook_filename)
  if (strmid(quicklook_basename, 9, 5) eq 'ucomp') then begin
    datetime = strmid(quicklook_basename, 0, 8)
  endif else begin
    datetime = strmid(quicklook_basename, 0, 15)
  endelse

  intensity_center_dashboard = ucomp_display_image(wave_region, intensity_center, $
                                                   type='intensity', $
                                                   name='Center wavelength intensity', $
                                                   reduce_factor=reduce_factor, $
                                                   datetime=datetime, $
                                                   run=run)

  enhanced_intensity_center_dashboard = ucomp_display_image(wave_region, enhanced_intensity_center, $
                                                            type='intensity', $
                                                            name='Enhanced intensity', $
                                                            reduce_factor=reduce_factor, $
                                                            /no_wave_region_annotation, $
                                                            run=run)

  peak_intensity_dashboard = ucomp_display_image(wave_region, intensity_center, $
                                                 type='intensity', $
                                                 name='Peak Intensity', $
                                                 reduce_factor=reduce_factor, $
                                                 /no_wave_region_annotation, $
                                                 run=run)

  doppler_shift_dashboard = ucomp_display_image(wave_region, doppler_shift, $
                                                type='doppler', $
                                                name='LOS velocity [km/s]', $
                                                reduce_factor=reduce_factor, $
                                                /no_wave_region_annotation, $
                                                run=run)

  line_width_dashboard = ucomp_display_image(wave_region, line_width, $
                                             type='line_width', $
                                             name='Line width (FWHM) [km/s]', $
                                             reduce_factor=reduce_factor, $
                                             /no_wave_region_annotation, $
                                             run=run)

  if (keyword_set(write_polarization)) then begin
    summed_intensity_dashboard = ucomp_display_image(wave_region, summed_intensity, $
                                                     type='intensity', $
                                                     name='Weighted average I', $
                                                     reduce_factor=reduce_factor, $
                                                     /no_wave_region_annotation, $
                                                     run=run)

    summed_q_i_dashboard = ucomp_display_image(wave_region, summed_q_i, $
                                               type='quv_i', $
                                               name='Weighted average Q / I', $
                                               reduce_factor=reduce_factor, $
                                               /no_wave_region_annotation, $
                                               run=run)

    summed_u_i_dashboard = ucomp_display_image(wave_region, summed_u_i, $
                                               type='quv_i', $
                                               name='Weighted average U / I', $
                                               reduce_factor=reduce_factor, $
                                               /no_wave_region_annotation, $
                                               run=run)

    summed_linpol_i_dashboard = ucomp_display_image(wave_region, summed_linpol_i, $
                                                    type='linpol', $
                                                    name='Weighted average log!I10!N(L / I)', $
                                                    reduce_factor=reduce_factor, $
                                                    /no_wave_region_annotation, $
                                                    run=run)

    azimuth_dashboard = ucomp_display_image(wave_region, azimuth, $
                                            type='azimuth', $
                                            name='Weight average azimuth [deg]', $
                                            reduce_factor=reduce_factor, $
                                            /no_wave_region_annotation, $
                                            run=run)

    radial_azimuth_dashboard = ucomp_display_image(wave_region, radial_azimuth, $
                                                   type='radial_azimuth', $
                                                   name='Weighted average radial azimuth [deg]', $
                                                   reduce_factor=reduce_factor, $
                                                   /no_wave_region_annotation, $
                                                   run=run)
  end

  if (keyword_set(write_polarization)) then begin
    dashboard_image = bytarr(3, 3 * nx, 4 * ny)

    dashboard_image[0, 0 * nx, 3 * ny] = intensity_center_dashboard
    dashboard_image[0, 1 * nx, 3 * ny] = summed_q_i_dashboard
    dashboard_image[0, 2 * nx, 3 * ny] = doppler_shift_dashboard

    dashboard_image[0, 0 * nx, 2 * ny] = enhanced_intensity_center_dashboard
    dashboard_image[0, 1 * nx, 2 * ny] = summed_u_i_dashboard
    dashboard_image[0, 2 * nx, 2 * ny] = line_width_dashboard

    dashboard_image[0, 0 * nx, 1 * ny] = peak_intensity_dashboard
    dashboard_image[0, 1 * nx, 1 * ny] = summed_linpol_i_dashboard
    dashboard_image[0, 2 * nx, 1 * ny] = azimuth_dashboard

    dashboard_image[0, 0 * nx, 0 * ny] = summed_intensity_dashboard
    ; blank space
    dashboard_image[0, 2 * nx, 0 * ny] = radial_azimuth_dashboard
  endif else begin
    dashboard_image = bytarr(3, 2 * nx, 3 * ny)

    dashboard_image[0, 0 * nx, 2 * ny] = intensity_center_dashboard
    dashboard_image[0, 1 * nx, 2 * ny] = enhanced_intensity_center_dashboard

    dashboard_image[0, 0.5 * nx, 1 * ny] = peak_intensity_dashboard

    dashboard_image[0, 0 * nx, 0 * ny] = doppler_shift_dashboard
    dashboard_image[0, 1 * nx, 0 * ny] = line_width_dashboard
  endelse

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  basename = file_basename(quicklook_filename, '.png')
  base_filename = filepath(basename, root=file_dirname(quicklook_filename))

  write_png, base_filename + '.all.png', dashboard_image
  mg_log, 'wrote dashboard PNG', name=run.logger_name, /debug

  intensity_center_display = ucomp_display_image(wave_region, intensity_center, $
                                                 type='intensity', $
                                                 name='Center wavelength intensity', $
                                                 reduce_factor=1, $
                                                 datetime=datetime, $
                                                 run=run)
  intensity_center_filename = string(base_filename, format='%s.center_intensity.png')
  write_png, intensity_center_filename, intensity_center_display
  mg_log, 'wrote center wavelength I PNG', name=run.logger_name, /debug

  enhanced_intensity_center_display = ucomp_display_image(wave_region, $
                                                          enhanced_intensity_center, $
                                                          type='intensity', $
                                                          name='Enhanced intensity', $
                                                          reduce_factor=1, $
                                                          datetime=datetime, $
                                                          run=run)
  enhanced_intensity_filename = string(base_filename, format='%s.enhanced_intensity.png')
  write_png, enhanced_intensity_filename, enhanced_intensity_center_display
  mg_log, 'wrote enhanced intensity PNG', name=run.logger_name, /debug

  peak_intensity_display = ucomp_display_image(wave_region, intensity_center, $
                                               type='intensity', $
                                               name='Peak Intensity', $
                                               reduce_factor=1, $
                                               datetime=datetime, $
                                               run=run)
  peak_intensity_filename = string(base_filename, format='%s.peak_intensity.png')
  write_png, peak_intensity_filename, peak_intensity_display
  mg_log, 'wrote peak intensity PNG', name=run.logger_name, /debug

  doppler_shift_display = ucomp_display_image(wave_region, doppler_shift, $
                                              type='doppler', $
                                              name='LOS velocity [km/s]', $
                                              reduce_factor=1, $
                                              datetime=datetime, $
                                              run=run)
  doppler_shift_filename = string(base_filename, format='%s.los_velocity.png')
  write_png, doppler_shift_filename, doppler_shift_display
  mg_log, 'wrote LOS velocity PNG', name=run.logger_name, /debug

  line_width_display = ucomp_display_image(wave_region, line_width, $
                                           type='line_width', $
                                           name='Line width (FWHM) [km/s]', $
                                           reduce_factor=1, $
                                           datetime=datetime, $
                                           run=run)
  line_width_filename = string(base_filename, format='%s.line_width.png')
  write_png, line_width_filename, line_width_display
  mg_log, 'wrote line width PNG', name=run.logger_name, /debug

   ; polarization images
  if (keyword_set(write_polarization)) then begin
    summed_intensity_display = ucomp_display_image(wave_region, $
                                                   summed_intensity, $
                                                   type='intensity', $
                                                   name='Weighted average I', $
                                                   reduce_factor=1, $
                                                   datetime=datetime, $
                                                   run=run)
    summed_intensity_filename = string(base_filename, format='%s.weighted_average_intensity.png')
    write_png, summed_intensity_filename, summed_intensity_display
    mg_log, 'wrote weighted average I PNG', name=run.logger_name, /debug

    summed_q_i_display = ucomp_display_image(wave_region, $
                                             summed_q_i, $
                                             type='quv_i', $
                                             name='Weighted average Q / I', $
                                             reduce_factor=1, $
                                             datetime=datetime, $
                                             run=run)
    summed_q_i_filename = string(base_filename, format='%s.weighted_average_q.png')
    write_png, summed_q_i_filename, summed_q_i_display
    mg_log, 'wrote weighted average Q / I PNG', name=run.logger_name, /debug

    summed_u_i_display = ucomp_display_image(wave_region, $
                                             summed_u_i, $
                                             type='quv_i', $
                                             name='Weighted average U / I', $
                                             reduce_factor=1, $
                                             datetime=datetime, $
                                             run=run)
    summed_u_i_filename = string(base_filename, format='%s.weighted_average_u.png')
    write_png, summed_u_i_filename, summed_u_i_display
    mg_log, 'wrote weighted average U / I PNG', name=run.logger_name, /debug

    summed_linpol_i_display = ucomp_display_image(wave_region, $
                                                  summed_linpol_i, $
                                                  type='linpol', $
                                                  name='Weighted average log!I10!N(L / I)', $
                                                  reduce_factor=1, $
                                                  datetime=datetime, $
                                                  run=run)
    summed_linpol_i_filename = string(base_filename, format='%s.weighted_average_linear_polarization.png')
    write_png, summed_linpol_i_filename, summed_linpol_i_display
    mg_log, 'wrote weighted average L / I PNG', name=run.logger_name, /debug

    azimuth_display = ucomp_display_image(wave_region, azimuth, $
                                          type='azimuth', $
                                          name='Azimuth [deg]', $
                                          reduce_factor=1, $
                                          datetime=datetime, $
                                          run=run)
    azimuth_filename = string(base_filename, format='%s.weighted_average_azimuth.png')
    write_png, azimuth_filename, azimuth_display
    mg_log, 'wrote azimuth PNG', name=run.logger_name, /debug

    radial_azimuth_display = ucomp_display_image(wave_region, radial_azimuth, $
                                                 type='radial_azimuth', $
                                                 name='Radial azimuth [deg]', $
                                                 reduce_factor=1, $
                                                 datetime=datetime, $
                                                 run=run)
    radial_azimuth_filename = string(base_filename, format='%s.weighted_average_radial_azimuth.png')
    write_png, radial_azimuth_filename, radial_azimuth_display
    mg_log, 'wrote radial azimuth PNG', name=run.logger_name, /debug

  endif
end
