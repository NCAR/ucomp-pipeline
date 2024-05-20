date = '20240409'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

l0_basename = '20240409.214658.17.ucomp.1074.l0.fts'
l0_filename = filepath(l0_basename, $
                       subdir=date, $
                       root=run->config('raw/basedir'))
file = ucomp_file(l0_filename, run=run)

l1_basename = '20240409.214658.ucomp.1074.l1.p5.fts'
l1_filename = filepath(l1_basename, $
                       subdir=[date, 'level1'], $
                       root=run->config('processing/basedir'))

ucomp_read_l1_data, l1_filename, $
                    primary_header=primary_header, $
                    ext_data=data, $
                    n_wavelengths=n_wavelengths
file.n_extensions = n_wavelengths

file.rcam_geometry = ucomp_geometry(occulter_radius=ucomp_getpar(primary_header, 'RADIUS0'), $
                                    post_angle=ucomp_getpar(primary_header, 'POST_ANG'))
file.tcam_geometry = ucomp_geometry(occulter_radius=ucomp_getpar(primary_header, 'RADIUS1'), $
                                    post_angle=ucomp_getpar(primary_header, 'POST_ANG'))

ucomp_write_intensity_image, file, data, primary_header, /grid, run=run

obj_destroy, file
obj_destroy, run

end
