; main-level example program

;date = '20220105'
date = '20211213'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

;l0_basename = '20220105.204523.49.ucomp.1074.l0.fts'
l0_basename = '20211213.190812.67.ucomp.1074.l0.fts'
l0_filename = filepath(l0_basename, $
                       subdir=date, $
                       root=run->config('raw/basedir'))
file = ucomp_file(l0_filename, run=run)

;l1_basename = '20220105.204523.ucomp.1074.l1.5.fts'
l1_basename = '20211213.190812.ucomp.1074.l1.5.fts'
l1_filename = filepath(l1_basename, $
                       subdir=[date, 'level1'], $
                       root=run->config('processing/basedir'))

ucomp_read_l1_data, l1_filename, $
                    primary_header=primary_header, $
                    ext_data=data, $
                    n_wavelengths=n_wavelengths
file.n_extensions = n_wavelengths

ucomp_write_nrgf_image, file, primary_header, data, run=run

obj_destroy, file
obj_destroy, run

end
