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
;   average_filenames : in, required, type=string
;     average filenames to create quick inverts for
;
; :Keywords:
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

      center_intensity = reform(ext_data[*, *, 0, center_index - 1:center_index + 1])

      integrated_intensity = ucomp_integrate(reform(ext_data[*, *, 0, *]), center_index=center_index)
      integrated_q         = ucomp_integrate(reform(ext_data[*, *, 1, *]), center_index=center_index)
      integrated_u         = ucomp_integrate(reform(ext_data[*, *, 2, *]), center_index=center_index)
      integrated_linpol    = sqrt(integrated_q^2 + integrated_u^2)

      azimuth = ucomp_azimuth(integrated_q, integrated_u, radial_azimuth=radial_azimuth)

      d_lambda = wavelengths[center_index] - wavelengths[center_index - 1]
      ucomp_analytic_gauss_fit, center_intensity[*, *, 0], $
                                center_intensity[*, *, 1], $
                                center_intensity[*, *, 2], $
                                d_lambda, $
                                doppler_shift=doppler_shift, $
                                line_width=line_width, $
                                peak_intensity=peak_intensity

      if (run->config('display/mask_l2')) then begin
        ; mask outputs
        dims = size(integrated_intensity, /dimensions)
        field_mask = ucomp_field_mask(dims[0], $
                                      dims[1], $
                                      run->epoch('field_radius'))
        occulter_radius = ucomp_getpar(primary_header, 'RADIUS')
        p_angle = ucomp_getpar(primary_header, 'SOLAR_P0')
        occulter_mask = ucomp_occulter_mask(dims[0], dims[1], occulter_radius)
        offsensor_mask = ucomp_offsensor_mask(dims[0], dims[1], p_angle)
        mask = field_mask and occulter_mask and offsensor_mask
        outside_mask_indices = where(mask eq 0, n_outside_mask)

        if (n_outside_mask gt 0L) then begin
          integrated_intensity[outside_mask_indices] = !values.f_nan
          integrated_q[outside_mask_indices]         = !values.f_nan
          integrated_u[outside_mask_indices]         = !values.f_nan
          integrated_linpol[outside_mask_indices]    = !values.f_nan
          line_width[outside_mask_indices]           = !values.f_nan
          doppler_shift[outside_mask_indices]        = !values.f_nan
          azimuth[outside_mask_indices]              = !values.f_nan
          radial_azimuth[outside_mask_indices]       = !values.f_nan
        endif
      endif

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
      integrated_q_i = integrated_q / integrated_intensity
      fits_write, fcb, integrated_q_i, ext_header, $
                  extname='Integrated Q / I'

      integrated_u_i = integrated_u / integrated_intensity
      fits_write, fcb, integrated_u_i, ext_header, $
                  extname='Integrated U / I'

      integrated_linpol_i = integrated_linpol / integrated_intensity
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

      image_filename = filepath(string(file_basename(basename, '.fts'), $
                                       format='%s.png'), root=l1_dir)
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
                                      run=run
    endif
  endfor
end
