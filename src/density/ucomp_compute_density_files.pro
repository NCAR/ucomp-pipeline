; docformat = 'rst'

pro ucomp_compute_density_files, l2_basename_1074, $
                                 l2_basename_1079, $
                                 output_basename, $
                                 run=run
  compile_opt strictarr

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  l2_filename_1074 = filepath(l2_basename_1074, root=l2_dir)
  l2_filename_1079 = filepath(l2_basename_1079, root=l2_dir)

  fits_open, l2_filename_1074, fcb
  fits_read, fcb, !null, primary_1074_header, exten_no=0
  fits_read, fcb, peak_intensity_1074, peak_intensity_1074_header, extname='Peak intensity'
  fits_read, fcb, line_width_1074, line_width_1074_header, extname='Line width (FWHM)'
  fits_close, fcb

  fits_open, l2_filename_1079, fcb
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
                                  heights, densities, ratios, r_sun)

  output_filename = filepath(output_basename, root=l2_dir)

  fits_open, output_filename, fcb, /write
  ucomp_fits_write, fcb, density, primary_1074_header, /no_abort, message=error_msg
  if (error_msg ne '') then message, error_msg
  fits_close, fcb
end


; main-level example

date = '20220225'

f_1074 = '20220225.182056.ucomp.1074.l2.fts'
f_1079 = '20220225.182341.ucomp.1079.l2.fts'

config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

ucomp_compute_density_files, f_1074, f_1079, 'density.fts', run=run

obj_destroy, run

end
