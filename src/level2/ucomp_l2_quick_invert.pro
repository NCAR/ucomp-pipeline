; docformat = 'rst'

;+
; Produce the quick invert images:
;
; - integrated intensity
; - integrated Q/I
; - integrated U/I
; - integrated L/I
; - azimuth
; - radial azimuth
; - velocity
; - line width
;
; :Params:
;   wave_region : in, required, type=string
;     wave region, e.g., '1074'
;
; :Keywords:
;   average_filenames : in, required, type=string
;     average filenames to create quick inverts for
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_l2_quick_invert, wave_region, $
                           average_filenames=average_filenames, $
                           run=run
  compile_opt strictarr

  for f = 0L, n_elements(average_filenames) - 1L do begin
    if (average_filenames[f] ne '') then begin
      mg_log, 'creating quick invert for %s...', $
              file_basename(average_filenames[f]), $
              name=run.logger_name, /info

      if (~file_test(average_filenames[f])) then begin
        mg_log, '%s not found, skipping...', $
                file_basename(average_filenames[f]), $
                name=run.logger_name, /warn
        continue
      endif

      run.datetime = strmid(file_basename(average_filenames[f]), 0, 8)

      ucomp_read_l1_data, average_filenames[f], $
                          primary_header=primary_header, $
                          ext_data=ext_data, $
                          ext_headers=ext_headers, $
                          n_wavelengths=n_wavelengths

      wavelengths = fltarr(n_wavelengths)
      for e = 0L, n_wavelengths - 1L do begin
        wavelengths[e] = ucomp_getpar(ext_headers[e], 'WAVELNG')
      endfor
      center_index = n_wavelengths / 2L

      integrated_intensity = ucomp_integrate(reform(ext_data[*, *, 0, *]), center_index=center_index)
      integrated_q         = ucomp_integrate(reform(ext_data[*, *, 1, *]), center_index=center_index)
      integrated_u         = ucomp_integrate(reform(ext_data[*, *, 2, *]), center_index=center_index)
      integrated_linpol    = sqrt(integrated_q^2 + integrated_u^2)

      azimuth = ucomp_azimuth(integrated_q, integrated_u, radial_azimuth=radial_azimuth)

      intensity_blue   = reform(ext_data[*, *, 0, center_index - 1])
      intensity_center = reform(ext_data[*, *, 0, center_index])
      intensity_red    = reform(ext_data[*, *, 0, center_index + 1])
      d_lambda = wavelengths[center_index] - wavelengths[center_index - 1]

      ucomp_analytic_gauss_fit, intensity_blue, $
                                intensity_center, $
                                intensity_red, $
                                d_lambda, $
                                doppler_shift=doppler_shift, $
                                line_width=line_width, $
                                peak_intensity=peak_intensity

      integrated_q_i = integrated_q / integrated_intensity
      integrated_u_i = integrated_u / integrated_intensity
      integrated_linpol_i = integrated_linpol / integrated_intensity

      c = 299792.458D

      ; convert Doppler shift to velocity [km/s]
      doppler_shift *= c / mean(wavelengths)

      ; convert line width to velocity (km/s)
      line_width *= c / mean(wavelengths)

      ; mask data on various thresholds
      ; TODO: constants should be retrieved from wave region config file
      if (run->config('quickinvert/mask_noise')) then begin
        good_indices = where(integrated_intensity gt 0.25 $
                               and integrated_intensity lt 120.0, $
                               complement=bad_indices, /null)

        integrated_intensity[bad_indices] = !values.f_nan
        integrated_q_i[bad_indices]       = !values.f_nan
        integrated_u_i[bad_indices]       = !values.f_nan
        integrated_linpol_i[bad_indices]  = !values.f_nan
        azimuth[bad_indices]              = !values.f_nan
        radial_azimuth[bad_indices]       = !values.f_nan
        doppler_shift[bad_indices]        = !values.f_nan
        line_width[bad_indices]           = !values.f_nan
      endif

      doppler_shift -= median(doppler_shift) - 1.0

      l2_dirname = filepath('', $
                            subdir=[run.date, 'level2'], $
                            root=run->config('processing/basedir'))
      ucomp_mkdir, l2_dirname, logger_name=run.logger_name
      basename = string(file_basename(average_filenames[f], '.fts'), format='%s.quick_invert.fts')
      filename = filepath(basename, root=l2_dirname)

      ext_header = ext_headers[0]
      sxdelpar, ext_header, 'WAVELNG'

      fits_open, filename, fcb, /write
      fits_write, fcb, 0.0, primary_header

      ucomp_addpar, ext_header, 'UNITS', 'ppm of solar disk', after='OBJECT'
      fits_write, fcb, integrated_intensity, ext_header, $
                  extname='Integrated intensity'

      ucomp_addpar, ext_header, 'UNITS', 'fraction'

      fits_write, fcb, integrated_q_i, ext_header, $
                  extname='Integrated Q / I'

      fits_write, fcb, integrated_u_i, ext_header, $
                  extname='Integrated U / I'

      fits_write, fcb, integrated_linpol_i, ext_header, $
                  extname='Integrated L / I'

      ucomp_addpar, ext_header, 'UNITS', 'deg CCW from horizontal'
      fits_write, fcb, azimuth, ext_header, extname='Azimuth'

      ucomp_addpar, ext_header, 'UNITS', 'deg CCW from radial'
      fits_write, fcb, radial_azimuth, ext_header, extname='Radial azimuth'

      ucomp_addpar, ext_header, 'UNITS', 'km/s'
      fits_write, fcb, doppler_shift, ext_header, extname='Doppler velocity'

      fits_write, fcb, line_width, ext_header, extname='Line width'

      fits_close, fcb

      occulter_radius = ucomp_getpar(primary_header, 'RADIUS')
      post_angle = ucomp_getpar(primary_header, 'POST_ANG')
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
                                      reduce_factor=2L, $
                                      wave_region=wave_region, $
                                      occulter_radius=occulter_radius, $
                                      post_angle=post_angle, $
                                      p_angle=p_angle, $
                                      run=run
    endif
  endfor
end


; main-level example program

date = '20220310'
wave_region = '1074'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

l2_dirname = filepath('', $
                      subdir=[run.date, 'level2'], $
                      root=run->config('processing/basedir'))

mean_basename = '20220310.ucomp.1074.synoptic.mean.fts'
mean_filename = filepath(mean_basename, root=l2_dirname)

ucomp_l2_quick_invert, wave_region, $
                       average_filenames=[mean_filename], $
                       run=run

obj_destroy, run

end
