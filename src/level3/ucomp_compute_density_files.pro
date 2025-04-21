; docformat = 'rst'

pro ucomp_compute_density_files, l2_basenames_1074, $
                                 l2_basenames_1079, $
                                 output_basename, $
                                 ignore_linewidth=ignore_linewidth, $
                                 run=run
  compile_opt strictarr

  mg_log, 'computing density for:', name=run.logger_name, /info
  for f = 0L, n_elements(l2_basenames_1074) - 1L do begin
    mg_log, '  %d/%d 1074 nm: %s', $
            f + 1 , n_elements(l2_basenames_1074), $
            file_basename(l2_basenames_1074[f]), $
            name=run.logger_name, /info
  endfor
  for f = 0L, n_elements(l2_basenames_1079) - 1L do begin
    mg_log, '  %d/%d 1079 nm: %s', $
            f + 1 , n_elements(l2_basenames_1079), $
            file_basename(l2_basenames_1079[f]), $
            name=run.logger_name, /info
  endfor

  l2_dirname = filepath('', $
                        subdir=[run.date, 'level2'], $
                        root=run->config('processing/basedir'))
  l3_dirname = filepath('', $
                        subdir=[run.date, 'level3'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l3_dirname, logger_name=run.logger_name

  l2_filenames_1074 = filepath(l2_basenames_1074, root=l2_dirname)
  ucomp_average_l2_files, l2_filenames_1074, $
                          primary_header=primary_1074_header, $
                          peak_intensity=peak_intensity_1074, $
                          header_peak_intensity=peak_intensity_1074_header, $
                          line_width=line_width_1074, $
                          header_line_width=line_width_1074_header, $
                          date_obs=date_obs_1074, $
                          date_end=date_end_1074

  l2_filenames_1079 = filepath(l2_basenames_1079, root=l2_dirname)
  ucomp_average_l2_files, l2_filenames_1079, $
                          primary_header=primary_1079_header, $
                          peak_intensity=peak_intensity_1079, $
                          header_peak_intensity=peak_intensity_1079_header, $
                          line_width=line_width_1079, $
                          header_line_width=line_width_1079_header, $
                          date_obs=date_obs_1079, $
                          date_end=date_end_1079

  center_wavelength_1074 = run->line('1074', 'center_wavelength')
  center_wavelength_1079 = run->line('1079', 'center_wavelength')

  density_basename = run->epoch('density_basename')
  density_filename = filepath(density_basename, $
                              subdir='density', $
                              root=run.resource_root)

  ratios = ucomp_read_density_ratio(density_filename, $
                                    heights=heights, $
                                    densities=densities, $
                                    chianti_version=chianti_version, $
                                    inverted_ratio=inverted_ratio, $
                                    electron_temperature=electron_temperature, $
                                    n_levels=n_levels, $
                                    abundances_basename=abundances_basename, $
                                    protons=protons, $
                                    limb_darkening=limb_darkening)

  r_sun = ucomp_getpar(primary_1074_header, 'R_SUN')

  density = ucomp_compute_density(peak_intensity_1074, peak_intensity_1079, $
                                  line_width_1074, line_width_1079, $
                                  center_wavelength_1074, center_wavelength_1079, $
                                  heights, densities, ratios, r_sun, $
                                  run->line('1074', 'noise_intensity_min'), $
                                  run->line('1074', 'noise_intensity_max'), $
                                  run->line('1079', 'noise_intensity_min'), $
                                  run->line('1079', 'noise_intensity_max'), $
                                  run->line('1074', 'noise_line_width_min'), $
                                  run->line('1074', 'noise_line_width_max'), $
                                  run->line('1079', 'noise_line_width_min'), $
                                  run->line('1079', 'noise_line_width_max'), $
                                  count=n_good_pixels, $
                                  ignore_linewidth=ignore_linewidth, $
                                  inverted_ratio=inverted_ratio, $
                                  in_ratio_range=in_ratio_range)

  mg_log, '%d good pixels', n_good_pixels, name=run.logger_name, /debug
  mg_log, '%d out-of-range ratio pixels', n_good_pixels - in_ratio_range, $
          name=run.logger_name, /debug
  output_filename = filepath(output_basename, root=l3_dirname)

  primary_header = primary_1074_header

  ucomp_addpar, primary_header, 'LEVEL', 'L3', comment='level 3 calibrated'
  ucomp_addpar, primary_header, 'FILTER', '1074/1079'

  ; adjust DATE-OBS, DATE-END
  date_obs_1074 = ucomp_getpar(primary_1074_header, 'DATE-OBS')
  date_obs_1079 = ucomp_getpar(primary_1079_header, 'DATE-OBS')
  date_end_1074 = ucomp_getpar(primary_1074_header, 'DATE-END')
  date_end_1079 = ucomp_getpar(primary_1079_header, 'DATE-END')
  date_obs = min([date_obs_1074, date_obs_1079])
  date_end = max([date_end_1074, date_end_1079])
  ucomp_addpar, primary_header, 'DATE-OBS', date_obs
  ucomp_addpar, primary_header, 'DATE-END', date_end

  ; adjust MJD-OBS, MJD-END
  ucomp_addpar, primary_header, 'MJD-OBS', ucomp_dateobs2julday(date_obs), $
                format='F0.9'
  ucomp_addpar, primary_header, 'MJD-END', ucomp_dateobs2julday(date_end), $
                format='F0.9'

  ; adjust CDELT{1,2} to be the average of the two platescales
  cdelt1 = (ucomp_getpar(primary_1074_header, 'CDELT1') + ucomp_getpar(primary_1079_header, 'CDELT1')) / 2.0
  cdelt2 = (ucomp_getpar(primary_1074_header, 'CDELT2') + ucomp_getpar(primary_1079_header, 'CDELT2')) / 2.0
  ucomp_addpar, primary_header, 'CDELT1', cdelt1, format='(f9.3)'
  ucomp_addpar, primary_header, 'CDELT2', cdelt2, format='(f9.3)'

  remove_sections = ['Level 1 processing info', 'Level 2 processing info', $
                     'Quality metrics', 'Camera info', 'Observing info', $
                     'Hardware settings', 'Temperatures', $
                     'SGS info', 'Weather info', 'Occulter centering info']
  ucomp_delpar, primary_header, remove_sections, /section
  ucomp_delpar, primary_header, /history

  ; add Level 3 processing section

  after = 'RSUN_REF'
  ucomp_addpar, primary_header, 'CHIANTIV', chianti_version, $
                comment='Chianti version used to calculate lookup table', $
                after=after
  ucomp_addpar, primary_header, 'CHIANTIF', density_basename, $
                comment='Chianti lookup table', $
                after=after
  for f = 0L, n_elements(l2_basenames_1074) - 1L do begin
    ucomp_addpar, primary_header, $
                  string(f + 1, format='1074FIL%d'), $
                  l2_basenames_1074[f], $
                  comment=string(f + 1, n_elements(l2_basenames_1074), $
                                 format='%d/%d level 2 1074 filename'), $
                  after=after
  endfor
  for f = 0L, n_elements(l2_basenames_1079) - 1L do begin
    ucomp_addpar, primary_header, $
                  string(f + 1, format='1079FIL%d'), $
                  l2_basenames_1079[f], $
                  comment=string(f + 1, n_elements(l2_basenames_1079), $
                                 format='%d/%d level 2 1079 filename'), $
                  after=after
  endfor
  ucomp_addpar, primary_header, 'N_LEVELS', n_levels, $
                comment='number of energy levels used', $
                after=after
  ucomp_addpar, primary_header, 'ELECTEMP', electron_temperature, $
                comment='[K] electron temperature', $
                format='(f0.1)', $
                after=after
  ucomp_addpar, primary_header, 'ABUND', abundances_basename, $
                comment='abundances filename', $
                after=after
  ucomp_addpar, primary_header, 'PROTONS', boolean(protons), $
                comment='include protons', $
                after=after
  ucomp_addpar, primary_header, 'LIMBDARK', boolean(limb_darkening), $
                comment='include limb darkening', $
                after=after
  ucomp_addpar, primary_header, 'USELINEW', boolean(~keyword_set(ignore_linewidth)), $
                comment='use line width', $
                after=after

  ucomp_addpar, primary_header, 'COMMENT', 'Density', /title, before='CHIANTIV'

  fits_open, output_filename, fcb, /write
  ucomp_fits_write, fcb, density, primary_header, /no_abort, message=error_msg
  ucomp_fits_write, fcb, peak_intensity_1074, peak_intensity_1074_header, $
                    extname='Peak intensity [1074 nm]', $
                    /no_abort, message=error_msg
  ucomp_fits_write, fcb, line_width_1074, line_width_1074_header, $
                    extname='Line width (FWHM) [1074 nm]', $
                    /no_abort, message=error_msg
  ucomp_fits_write, fcb, peak_intensity_1079, peak_intensity_1079_header, $
                    extname='Peak intensity [1079 nm]', $
                    /no_abort, message=error_msg
  ucomp_fits_write, fcb, line_width_1079, line_width_1079_header, $
                    extname='Line width (FWHM) [1079 nm]', $
                    /no_abort, message=error_msg

  if (error_msg ne '') then message, error_msg
  fits_close, fcb

  ucomp_write_density_image, output_basename, run=run
end


; main-level example

; date = '20220225'
date = '20240409'
; date = '20220111'
; date = '20240330'
; date = '20220407'

; f_1074 = '20220225.182056.ucomp.1074.l2.fts'
; f_1079 = '20220225.182341.ucomp.1079.l2.fts'

; f_1074 = '20220111.192841.ucomp.1074.l2.fts'
; f_1079 = '20220111.193101.ucomp.1079.l2.fts'

; f_1074 = '20240330.201401.ucomp.1074.l2.fts'
; f_1079 = '20240330.204128.ucomp.1079.l2.fts'

; f_1074 = '20220407.181026.ucomp.1074.l2.fts'
; f_1079 = '20220407.181312.ucomp.1079.l2.fts'

; f_1074 = '20240409.191848.ucomp.1074.l2.fts'
; f_1079 = '20240409.191146.ucomp.1079.l2.fts'

; f_1074 = '20240409.193422.ucomp.1074.l2.fts'
; f_1079 =  '20240409.210322.ucomp.1079.l2.fts'

; f_1074 = '20240409.180747.ucomp.1074.l2.fts'
; f_1079 = '20240409.191146.ucomp.1079.l2.fts'

; f_1074 = '20240409.190537.ucomp.1074.l2.fts'
; f_1079 = '20240409.180009.ucomp.1079.l2.fts'

; f_1074 = '20240409.193422.ucomp.1074.l2.fts'
; f_1079 = '20240409.191146.ucomp.1079.l2.fts'

; f_1074 = '20240409.193422.ucomp.1074.l2.fts'
; f_1079 = '20240409.180009.ucomp.1079.l2.fts'

; f_1074 = '20240409.180747.ucomp.1074.l2.fts'
; f_1079 = '20240409.210322.ucomp.1079.l2.fts'

; f_1074 = '20240409.190537.ucomp.1074.l2.fts'
; f_1079 = '20240409.191146.ucomp.1079.l2.fts'

; f_1074 = ['20240409.190537.ucomp.1074.l2.fts', '20240409.191848.ucomp.1074.l2.fts']
; f_1079 = ['20240409.191146.ucomp.1079.l2.fts', '20240409.192457.ucomp.1079.l2.fts']

; #1
; f_1074 = '20240409.180747.ucomp.1074.l2.fts'
; f_1079 = '20240409.180009.ucomp.1079.l2.fts'

; #2
; f_1074 = '20240409.190537.ucomp.1074.l2.fts'
; f_1079 = '20240409.191146.ucomp.1079.l2.fts'

; #3
; f_1074 = '20240409.191848.ucomp.1074.l2.fts'
; f_1079 = '20240409.192457.ucomp.1079.l2.fts'

; table = 2
; ignore_linewidth = 1B
; name = string(table, ignore_linewidth ? 2 : 1, format='table%d.method%d')

; date = '20250323'
; f_1074 = '20250323.212823.ucomp.1074.l2.fts'
; f_1079 = '20250323.212354.ucomp.1079.l2.fts'

date = '20240409'
; f_1074 = '20240409.180747.ucomp.1074.l2.fts'
; f_1079 = '20240409.180009.ucomp.1079.l2.fts'

; f_1074 = '20240409.190537.ucomp.1074.l2.fts'
; f_1079 = '20240409.191146.ucomp.1079.l2.fts'

f_1074 = '20240409.210752.ucomp.1074.l2.fts'
f_1079 = '20240409.210322.ucomp.1079.l2.fts'

name = 'alin'

; config_basename = 'ucomp.production.cfg'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

output_basename = string(strmid(f_1074[0], 0, 15), strmid(f_1079[0], 9, 6), $
                         name, $
                         format='%s-%s.ucomp.1074-1079.%s.density.fts')
ucomp_compute_density_files, f_1074, f_1079, output_basename, $
                             ignore_linewidth=ignore_linewidth, run=run

obj_destroy, run

end
