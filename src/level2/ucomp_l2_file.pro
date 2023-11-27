; docformat = 'rst'

;+
; Produce a level 2 product from a level 1 file:
;
; - "Center wavelength intensity" [All wavelengths]
;   comment: "intensity at center tuning wavelength"
; - "Enhanced intensity" [All wavelengths]
;   comment: "unsharp mask of center wavelength intensity"
; - "Peak Intensity" [All wavelengths]
;   comment: "peak of Gaussian fit"
; - "LOS Velocity" [All wavelengths]
;   comment: "Doppler velocity from Gaussian fit"
; - "Line Width" [All wavelengths]
;   comment: "FWHM from Gaussian fit"
; - "Weighted average I" [1074/1079 only]
;   comment: "sum of I at center 3 wavelengths / 2"
; - "Weighted average Q" (Q/I in the quick look) [1074/1079 only]
;   comment: "sum of Q at center 3 wavelengths / 2"
; - "Weighted average U" (U/I in the quick look) [1074/1079 only]
;   comment: "sum of U at center 3 wavelengths / 2"
; - "Weighted average L" (Log L/I in the quick look) [1074/1079 only]
;   comment: "sum of L at center 3 wavelengths / 2"
; - "Azimuth" [1074/1079 only]
;   comment: "0.5 * atan(weighted U / weighted Q)"
; - "Radial Azimuth" [1074/1079 only]
;   comment: "azimuth with respect to radial direction"
;
; :Params:
;   filename : in, required, type=string
;     UCoMP level 1 filename (either individual level 1 file or an average
;     level 1 file)
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_l2_file, filename, run=run
  compile_opt strictarr

  basename = file_basename(filename)

  if (strmid(basename, 9, 5) eq 'ucomp') then begin
    run.datetime = strmid(basename, 0, 8)
  endif else begin
    run.datetime = strmid(basename, 0, 15)
  endelse

  if (~file_test(filename, /regular)) then begin
    mg_log, '%s does not exist', basename, $
            name=run.logger_name, /warn
    goto, done
  endif

  ucomp_read_l1_data, filename, $
                      primary_header=primary_header, $
                      ext_data=ext_data, $
                      ext_headers=ext_headers, $
                      n_wavelengths=n_wavelengths

  if (n_wavelengths lt 3L) then begin
    mg_log, '%s does not have at least 3 unique wavelengths', $
            basename, $
            name=run.logger_name, /warn
    goto, done
  endif

  date_obs = ucomp_getpar(primary_header, 'DATE-OBS')
  wave_region = ucomp_getpar(primary_header, 'FILTER')

  ; find center wavelength
  center_index = n_wavelengths / 2L

  wavelengths = fltarr(n_wavelengths)
  for w = 0L, n_wavelengths - 1L do begin
    wavelengths[w] = ucomp_getpar(ext_headers[w], 'WAVELNG')
  endfor

  post_angle      = ucomp_getpar(primary_header, 'POST_ANG')
  p_angle         = ucomp_getpar(primary_header, 'SOLAR_P0')
  occulter_radius = ucomp_getpar(primary_header, 'RADIUS')

  intensity_blue   = reform(ext_data[*, *, 0, center_index - 1])
  intensity_center = reform(ext_data[*, *, 0, center_index])
  intensity_red    = reform(ext_data[*, *, 0, center_index + 1])

  summed_intensity = ucomp_integrate(reform(ext_data[*, *, 0, *]))
  summed_q         = ucomp_integrate(reform(ext_data[*, *, 1, *]))
  summed_u         = ucomp_integrate(reform(ext_data[*, *, 2, *]))

  summed_linpol = sqrt(summed_q^2 + summed_u^2)

  d_lambda = wavelengths[center_index] - wavelengths[center_index - 1]

  ucomp_analytic_gauss_fit, intensity_blue, $
                            intensity_center, $
                            intensity_red, $
                            d_lambda, $
                            doppler_shift=doppler_shift, $
                            line_width=line_width, $
                            peak_intensity=peak_intensity

  c = 299792.458D

  ; convert Doppler shift to velocity [km/s]
  doppler_shift *= c / mean(wavelengths)

  ; convert line width to velocity [km/s]
  line_width *= c / mean(wavelengths)

  enhanced_intensity_center = ucomp_enhanced_intensity(intensity_center, $
      radius=run->line(wave_region, 'enhanced_intensity_radius'), $
      amount=run->line(wave_region, 'enhanced_intensity_amount'), $
      occulter_radius=occulter_radius, $
      post_angle=post_angle, $
      field_radius=run->epoch('field_radius'), $
      mask=run->config('display/mask_l2'))

  azimuth = ucomp_azimuth(summed_q, summed_u, radial_azimuth=radial_azimuth)

  !null = where(intensity_center gt run->line(wave_region, 'noise_intensity_center_min') $
                  and intensity_center lt run->line(wave_region, 'noise_intensity_center_max') $
                  and intensity_blue gt run->line(wave_region, 'noise_intensity_blue_min') $
                  and intensity_blue lt run->line(wave_region, 'noise_intensity_blue_max') $
                  and intensity_red gt run->line(wave_region, 'noise_intensity_red_min') $
                  and intensity_red lt run->line(wave_region, 'noise_intensity_red_max') $
                  and line_width gt run->line(wave_region, 'noise_line_width_min'), $
                  ; and line_width lt run->line(wave_region, 'noise_line_width_max'), $
                complement=noisy_indices, /null)

  noise_mask = intensity_center * 0.0 + 1.0
  noise_mask[noisy_indices] = 0.0

  ; mask data on various thresholds
  if (run->config('l2/mask_noise')) then begin
    intensity_center[noisy_indices]          = !values.f_nan
    enhanced_intensity_center[noisy_indices] = !values.f_nan
    peak_intensity[noisy_indices]            = !values.f_nan
    doppler_shift[noisy_indices]             = !values.f_nan
    line_width[noisy_indices]                = !values.f_nan

    summed_intensity[noisy_indices]          = !values.f_nan
    summed_q[noisy_indices]                  = !values.f_nan
    summed_u[noisy_indices]                  = !values.f_nan
    summed_linpol[noisy_indices]             = !values.f_nan
    azimuth[noisy_indices]                   = !values.f_nan
    radial_azimuth[noisy_indices]            = !values.f_nan
  endif

  dims = size(intensity_center, /dimensions)

  if (run->config('l2/mask_geometry')) then begin
    ; mask outputs
    mask = ucomp_mask(dims[0:1], $
                      field_radius=run->epoch('field_radius'), $
                      occulter_radius=occulter_radius + run->epoch('over_masking'), $
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
      summed_q[outside_mask_indices]                  = !values.f_nan
      summed_u[outside_mask_indices]                  = !values.f_nan
      summed_linpol[outside_mask_indices]             = !values.f_nan
      azimuth[outside_mask_indices]                   = !values.f_nan
      radial_azimuth[outside_mask_indices]            = !values.f_nan
    endif
  endif

  center_wavelength = run->line(wave_region, 'center_wavelength')

  x = rebin(reform(findgen(dims[0]) - (dims[0] - 1.0) / 2.0, dims[0], 1), dims[0], dims[1])

  year   = long(strmid(date_obs, 0, 4))
  month  = long(strmid(date_obs, 5, 2))
  day    = long(strmid(date_obs, 8, 2))
  hours  = long(strmid(date_obs, 11, 2))
  mins   = long(strmid(date_obs, 14, 2))
  secs   = long(strmid(date_obs, 17, 2))
  fhours = hours + mins / 60.0 + secs / 60.0 / 60.0

  sun, year, month, day, fhours, sd=rsun
  sun_pixels = rsun / run->line(wave_region, 'plate_scale')

  rstwvl_mask = intensity_center gt run->line(wave_region, 'rstwvl_intensity_center_min') $
    and intensity_center lt run->line(wave_region, 'rstwvl_intensity_center_max') $
    and intensity_blue gt run->line(wave_region, 'rstwvl_intensity_blue_min') $
    and intensity_blue lt run->line(wave_region, 'rstwvl_intensity_blue_max') $
    and intensity_red gt run->line(wave_region, 'rstwvl_intensity_red_min') $
    and intensity_red lt run->line(wave_region, 'rstwvl_intensity_red_max') $
    and line_width gt run->line(wave_region, 'rstwvl_line_width_min') $
    and line_width lt run->line(wave_region, 'rstwvl_line_width_max') $
    and abs(doppler_shift) lt run->line(wave_region, 'rstwvl_velocity_threshold') $
    and doppler_shift ne 0.0 $
    and finite(doppler_shift) $
    and ucomp_annulus(0.0, 1.25 * sun_pixels, dimensions=dims)

  east_indices = where(rstwvl_mask and x lt 0.0, n_east_indices)
  west_indices = where(rstwvl_mask and x gt 0.0, n_west_indices)

  if (n_east_indices gt 0L && n_west_indices gt 0L) then begin
    east_rest_wavelength = median([doppler_shift[east_indices]])
    west_rest_wavelength = median([doppler_shift[west_indices]])
    file_rest_wavelength = (east_rest_wavelength + west_rest_wavelength) / 2.0
  endif else begin
    file_rest_wavelength = median(doppler_shift)
  endelse
  mg_log, 'rest wavelength from data: %0.2f km/s', file_rest_wavelength, $
          name=run.logger_name, /debug

  coeffs = run->line(wave_region, 'rstwvl_fit')
  model_rest_wavelength = ucomp_rest_wavelength(run.date, coeffs)

  wave_offset = ucomp_getpar(primary_header, 'WAVOFF')
  wave_region_offset = run->line(wave_region, 'rstwvl_offset')

  model_rest_wavelength -= center_wavelength + wave_region_offset - wave_offset
  model_rest_wavelength *= c / center_wavelength

  mg_log, 'rest wavelength from model: %0.2f km/s', $
          model_rest_wavelength, $
          name=run.logger_name, /debug

  ; find rest wavelength
  rstwvl_method = run->line(wave_region, 'rstwvl_method')
  case strlowcase(rstwvl_method) of
    'data': begin
        rest_wavelength = file_rest_wavelength
        rstwvl_method_keyword = 'image'
      end
    'model': begin
        rest_wavelength = model_rest_wavelength
        rstwvl_method_keyword = 'model fit'
      end
    else: begin
        fmt = 'unknown rest wavelength calculation method: %s'
        message, string(rstwvl_method, format=fmt)
      end
  endcase

  ; apply rest wavelength
  doppler_shift -= rest_wavelength

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    ucomp_mkdir, l2_dir, logger_name=run.logger_name
  endif

  ; write level 2 file, either one of the below, depending on the input level 1
  ; filename:
  ; - YYYYMMDD.HHMMSS.ucomp.WWWW.l1.pN.fts
  ; - YYYYMMDD.ucomp.WWWW.l1.PROGRAM.AVERAGE_TYPE.fts
  if (strmid(basename, 9, 5) eq 'ucomp') then begin
    parts = strsplit(basename, '.', /extract)
    ; this will have an issue if the program name ever has a "." in it
    l2_basename = string(parts[0], parts[2], parts[4], parts[5], $
                         format='%s.ucomp.%s.l2.%s.%s.fts')
  endif else begin
    parts = strsplit(basename, '.', /extract)
    l2_basename = string(parts[0], parts[1], parts[3], $
                         format='%s.%s.ucomp.%s.l2.fts')
  endelse
  l2_filename = filepath(l2_basename, root=l2_dir)

  mg_log, 'writing %s', l2_basename, name=run.logger_name, /debug

  ; promote header
  ucomp_addpar, primary_header, 'LEVEL', 'L2', comment='level 2 calibrated'

  after = 'BOPAL'
  current_time = systime(/utc)
  date_dp = string(bin_date(current_time), $
                   format='(%"%04d-%02d-%02dT%02d:%02d:%02d")')
  ucomp_addpar, primary_header, 'DATE_DP2', date_dp, $
                comment='[UT] L2 processing date/time', $
                after=after
  version = ucomp_version(revision=revision, branch=branch, date=code_date)
  ucomp_addpar, primary_header, 'DPSWID2',  $
                string(version, revision, $
                       format='(%"%s [%s]")'), $
                comment=string(code_date, branch, $
                       format='(%"L2 processing software (%s) [%s]")'), $
                after=after
  ucomp_addpar, primary_header, 'D_LAMBDA', d_lambda, $
                comment='[nm] wavelength spacing', $
                after=after, format='(F0.3)'
  ucomp_addpar, primary_header, 'COMMENT', 'Level 2 processing info', $
                before='DATE_DP2', /title

  fits_open, l2_filename, fcb, /write
  ucomp_fits_write, fcb, 0.0, primary_header, /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  center_header = ext_headers[center_index]

  delete_keywords = ['RAWEXTS', $
                     'RAWDARK1', 'DARKEXT1', 'RAWDARK2', 'DARKEXT2', $
                     'FLTFILE1', 'FLTEXTS1', 'MFLTEXT1', $
                     'FLTFILE2', 'FLTEXTS2', 'MFLTEXT2']
  for k = 0L, n_elements(delete_keywords) - 1L do begin
    sxdelpar, center_header, delete_keywords[k]
  endfor

  ; write center line intensity
  ucomp_fits_write, fcb, $
                    float(intensity_center), $
                    center_header, $
                    extname='Center wavelength intensity', $
                    ext_comment='intensity at center tuning wavelength', $
                    /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write enhanced center line intensity
  ucomp_fits_write, fcb, $
                    float(enhanced_intensity_center), $
                    center_header, $
                    extname='Enhanced intensity', $
                    ext_comment='unsharp mask of center wavelength intensity', $
                    /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  header = ext_headers[0]
  sxdelpar, header, 'WAVELNG'

  delete_keywords = ['RAWEXTS', $
                     'RAWDARK1', 'DARKEXT1', 'RAWDARK2', 'DARKEXT2', $
                     'FLTFILE1', 'FLTEXTS1', 'MFLTEXT1', $
                     'FLTFILE2', 'FLTEXTS2', 'MFLTEXT2']
  for k = 0L, n_elements(delete_keywords) - 1L do begin
    sxdelpar, header, delete_keywords[k]
  endfor

  ; write peak intensity
  ucomp_fits_write, fcb, $
                    float(peak_intensity), $
                    header, $
                    extname='Peak intensity', $
                    ext_comment='peak of Gaussian fit', $
                    /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  ; write LOS velocity
  ucomp_addpar, header, 'RSTWVL', rest_wavelength, $
                comment=' [km/s] median rest wavelength', $
                format='(F0.3)', $
                before='SKYTRANS'
  ucomp_addpar, header, 'RSTMTHD', rstwvl_method_keyword, $
                comment='rest wavelength computation method', $
                after='RSTWVL'
  ucomp_addpar, header, 'WAVOFF2', $
                rstwvl_method_keyword eq 'model fit' ? wave_region_offset : !null, $
                comment='[nm] offset for center wavelength', $
                format='(F0.3)', $
                after='RSTMTHD'
  ucomp_fits_write, fcb, $
                    float(doppler_shift), $
                    header, $
                    extname='LOS velocity', $
                    ext_comment='Doppler velocity from Gaussian fit', $
                    /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg
  sxdelpar, header, 'RSTWVL'
  sxdelpar, header, 'RSTMTHD'
  sxdelpar, header, 'WAVOFF2'

  ; write line width
  line_width_fwhm = float(line_width) * run->epoch('fwhm_factor')
  ucomp_fits_write, fcb, $
                    float(line_width_fwhm), $
                    header, $
                    extname='Line width (FWHM)', $
                    ext_comment='FWHM from Gaussian fit', $
                    /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg

  if (~run->config('l2/mask_noise')) then begin
    ucomp_fits_write, fcb, $
                      float(noise_mask), $
                      header, $
                      extname='Noise mask', $
                      ext_comment='mask low signal data', $
                      /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg
  endif

  write_polarization = run->config(wave_region + '/publish_type') eq 'all'
  if (write_polarization) then begin
    ; write summed I
    ucomp_fits_write, fcb, $
                      float(summed_intensity), $
                      header, $
                      extname='Weighted average I', $
                      ext_comment='sum of I at center 3 wavelengths / 2', $
                      /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg

    ; write summed Q
    ucomp_fits_write, fcb, $
                      float(summed_q), $
                      header, $
                      extname='Weighted average Q', $
                      ext_comment='sum of Q at center 3 wavelengths / 2', $
                      /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg

    ; write summed U
    ucomp_fits_write, fcb, $
                      float(summed_u), $
                      header, $
                      extname='Weighted average U', $
                      ext_comment='sum of U at center 3 wavelengths / 2', $
                      /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg

    ; write summed linear polarization
    ucomp_fits_write, fcb, $
                      float(summed_linpol), $
                      header, $
                      extname='Weighted average L', $
                      ext_comment='sum of L at center 3 wavelengths / 2', $
                      /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg

    ; write azimuth
    ucomp_fits_write, fcb, $
                      float(azimuth), $
                      header, $
                      extname='Azimuth', $
                      ext_comment='0.5 * atan(weighted U / weighted Q)', $
                      /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg

    ; write radial azimuth
    ucomp_fits_write, fcb, $
                      float(radial_azimuth), $
                      header, $
                      extname='Radial azimuth', $
                      ext_comment='azimuth with respect to radial direction', $
                      /no_abort, message=error_msg
    if (error_msg ne '') then message, error_msg
  endif

  fits_close, fcb

  if (run->config('display/mask_l2_noise')) then begin
    ; intensity_center[noisy_indices]          = !values.f_nan
    ; enhanced_intensity_center[noisy_indices] = !values.f_nan
    ; peak_intensity[noisy_indices]            = !values.f_nan
    doppler_shift[noisy_indices]             = !values.f_nan
    line_width[noisy_indices]                = !values.f_nan

    ; summed_intensity[noisy_indices]          = !values.f_nan
    summed_q[noisy_indices]                  = !values.f_nan
    summed_u[noisy_indices]                  = !values.f_nan
    summed_linpol[noisy_indices]             = !values.f_nan
    azimuth[noisy_indices]                   = !values.f_nan
    radial_azimuth[noisy_indices]            = !values.f_nan
  endif

  quicklook_basename = file_basename(l2_basename, '.fts') + '.png'
  quicklook_filename = filepath(quicklook_basename, root=l2_dir)

  ucomp_write_l2_images, quicklook_filename, $

                         ; dynamics images
                         intensity_center, $
                         enhanced_intensity_center, $
                         peak_intensity, $
                         doppler_shift, $
                         line_width_fwhm, $

                         ; polarization images
                         summed_intensity, $
                         summed_q / summed_intensity, $
                         summed_u / summed_intensity, $
                         summed_linpol / summed_intensity, $
                         azimuth, $
                         radial_azimuth, $

                         write_polarization=write_polarization, $
                         reduce_factor=4L, $
                         wave_region=wave_region, $
                         post_angle=post_angle, $
                         p_angle=p_angle, $
                         occulter_radius=occulter_radius, $

                         run=run

  done:
end


; main-level example program

date = '20220901'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

l0_basename = '20220901.182014.02.ucomp.1074.l0.fts'
l0_filename = filepath(l0_basename, $
                       subdir=[date], $
                       root=run->config('raw/basedir'))

file = ucomp_file(l0_filename, run=run)
file->update, 'level1'

ucomp_l2_file, file.l1_filename, run=run

average_basename = '20220901.ucomp.1074.l1.synoptic.mean.fts'
average_filename = filepath(average_basename, $
                            subdir=[date, 'level2'], $
                            root=run->config('processing/basedir'))
ucomp_l2_file, average_filename, run=run

obj_destroy, run

end
