; docformat = 'rst'

pro ucomp_compute_density_files, l2_basename_1074, $
                                 l2_basename_1079, $
                                 output_basename, $
                                 run=run
  compile_opt strictarr

  mg_log, 'computing density for:', name=run.logger_name, /info
  mg_log, '  %s', file_basename(l2_basename_1074), name=run.logger_name, /info
  mg_log, '  %s', file_basename(l2_basename_1079), name=run.logger_name, /info

  l2_dirname = filepath('', $
                        subdir=[run.date, 'level2'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l2_dirname, logger_name=run.logger_name

  l2_filename_1074 = filepath(l2_basename_1074, root=l2_dirname)
  l2_filename_1079 = filepath(l2_basename_1079, root=l2_dirname)

  fits_open, l2_filename_1074, fcb
  fits_read, fcb, !null, primary_1074_header, exten_no=0
  fits_read, fcb, peak_intensity_1074, peak_intensity_1074_header, extname='Peak intensity'
  fits_read, fcb, line_width_1074, line_width_1074_header, extname='Line width (FWHM)'
  fits_close, fcb

  fits_open, l2_filename_1079, fcb
  fits_read, fcb, !null, primary_1079_header, exten_no=0
  fits_read, fcb, peak_intensity_1079, peak_intensity_1079_header, extname='Peak intensity'
  fits_read, fcb, line_width_1079, line_width_1079_header, extname='Line width (FWHM)'
  fits_close, fcb

  center_wavelength_1074 = run->line('1074', 'center_wavelength')
  center_wavelength_1079 = run->line('1079', 'center_wavelength')

  density_ncdf_basename = run->epoch('density_basename')
  density_ncdf_filename = filepath(density_ncdf_basename, $
                                   subdir='density', $
                                   root=run.resource_root)

  ; lookup heights, densities, ratios from resource netCDF file
  heights = mg_nc_getdata(density_ncdf_filename, 'h')
  densities = mg_nc_getdata(density_ncdf_filename, 'den')
  ratios = mg_nc_getdata(density_ncdf_filename, 'rat')

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
                                  in_ratio_range=in_ratio_range)

  mg_log, '%d good pixels', n_good_pixels, name=run.logger_name, /debug
  mg_log, '%d out-of-range ratio pixels', n_good_pixels - in_ratio_range, $
          name=run.logger_name, /debug
  output_filename = filepath(output_basename, root=l2_dirname)

  primary_header = primary_1074_header

  ucomp_addpar, primary_header, 'LEVEL', 'L3', comment='level 3 calibrated'

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

  ; TODO: add Chianti version, Chianti database file

  remove_keywords = ['SGSSCINT', 'SGSDIMV', 'SGSDIMS', 'SGSSUMV', 'SGSSUMS', $
                     'SGSRAV', 'SGSRAS', 'SGSDECV', 'SGSDECS', 'SGSLOOP', $
                     'SGSRAZR', 'SGSDECZR', $
                     'T_RACK', 'T_LCVR1', 'T_LCVR2', 'T_LCVR3', 'T_LNB1', $
                     'T_MOD', 'T_LNB2', 'T_LCVR4', 'T_LCVR5', 'T_BASE', $
                     'TU_RACK', 'TU_LCVR1', 'TU_LCVR2', 'TU_LCVR3', 'TU_LNB1', $
                     'TU_MOD', 'TU_LNB2', 'TU_LCVR4', 'TU_LCVR5', 'TU_BASE', $
                     'TU_C0ARR', 'TU_C0PCB', 'TU_C1ARR', 'TU_C1PCB', $
                     'XOFFSET0', 'YOFFSET0', 'RADIUS0', 'FITCHI0', $
                     'XOFFSET1', 'YOFFSET1', 'RADIUS1', 'FITCHI1', $
                     'POST_ANG', 'RADIUS', 'IMAGESCL', 'RCAMECC', 'TCAMECC', $
                     'WNDSPD', 'WNDDIR', $
                     'CONTIN', 'OCCLTR', 'OCCLTR', 'O1FOCUS', $
                     'VCROSSTK', 'MED_BKG', $
                     'NUMSAT0O', 'NUMSAT1O', 'NUMSAT0C', 'NUMSAT1C', $
                     'NUMNL0O', 'NUMNL1O', 'NUMNL0C', 'NUMNL1C', $
                     'EXPTIME', 'FRAMERT', 'GAIN', 'SAVEALL', $
                     'TCAMID', 'RCAMID', 'TCAMLUT', 'RCAMLUT', $
                     'TCAMNUC', 'RCAMNUC', $
                     'NFRAME', 'REMFRAME', $
                     'NUMWAVE', 'NUMSUM', 'NREPEAT', 'NUMBEAM', $
                     'OCCLTR', 'OCCLTR', $
                     'DARKID', 'O1ID', 'DIFFSRID', 'OCCLTRID', $
                     'FLCVNEG', 'FLCVPOS', 'POLHOFF', 'REDHOFF', $
                     'T_COMPS', 'WAVOFF', 'LCVRELX', $
                     'FILTFWHM', $
                     'CONTOFF', $
                     'OBSERVER', 'OBS_ID', 'OBS_IDAU', 'OBS_IDDA', 'OBS_IDVE', $
                     'OBS_PLAN', 'OBS_PLAU', 'OBS_PLDA', 'OBS_PLVE', $
                     'OCCLTR-X', 'OCCLTR-Y', $
                     'DOI', 'DATE_DP', 'DPSWID', 'LIN_CRCT', 'DEMODV', $
                     'CONTSUB', 'CAMERAS', 'BOPAL', $
                     'DATE_DP2', 'DPSWID2', 'D_LAMBDA']

  for k = 0L, n_elements(remove_keywords) - 1L do begin
    sxdelpar, primary_header, remove_keywords[k]
  endfor

  ; remove HISTORY and unneeded COMMENTS
  comment_index = where(strmatch(primary_header, 'COMMENT --- Level 1 processing info ---*'), /null)
  if (n_elements(comment_index) gt 0L) then begin
    primary_header = primary_header[[lindgen(comment_index[0]), n_elements(primary_header) - 1]]
  endif

  ; TODO: add Level 3 processing section

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
; date = '20240409'
date = '20220111'

; f_1074 = '20220225.182056.ucomp.1074.l2.fts'
; f_1079 = '20220225.182341.ucomp.1079.l2.fts'

; f_1074 = '20240409.191848.ucomp.1074.l2.fts'
; f_1079 = '20240409.191146.ucomp.1079.l2.fts'

f_1074 = '20220111.192841.ucomp.1074.l2.fts'
f_1079 = '20220111.193101.ucomp.1079.l2.fts'


config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

output_basename = string(strmid(f_1074, 0, 15), strmid(f_1079, 9, 6), $
                         format='%s-%s.ucomp.1074-1079.density.fts')
ucomp_compute_density_files, f_1074, f_1079, output_basename, run=run

obj_destroy, run

end
