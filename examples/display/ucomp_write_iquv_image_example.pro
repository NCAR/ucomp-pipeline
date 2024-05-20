; main-level example program

; date = '20220105'
; date = '20220727'
date = '20220901'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

; l0_basename = '20220105.204523.49.ucomp.1074.l0.fts'
; l0_basename = '20220727.225643.89.ucomp.1074.l0.fts'
; l0_basename = '20220902.024545.71.ucomp.1074.l0.fts'
l0_basename = '20220902.031311.23.ucomp.706.l0.fts'
l0_filename = filepath(l0_basename, $
                       subdir=date, $
                       root=run->config('raw/basedir'))
file = ucomp_file(l0_filename, run=run)

; l1_basename = '20220105.204523.ucomp.1074.l1.5.fts'
; l1_basename = '20220727.225643.ucomp.1074.l1.3.fts'
; l1_basename = '20220902.024545.ucomp.1074.l1.3.fts'
l1_basename = '20220902.031311.ucomp.706.l1.3.fts'
l1_filename = filepath(l1_basename, $
                       subdir=[date, 'level1'], $
                       root=run->config('processing/basedir'))

ucomp_read_l1_data, l1_filename, ext_data=data, n_wavelengths=n_wavelengths, $
                    primary_header=primary_header
file.n_extensions = n_wavelengths

occulter_radius = ucomp_getpar(primary_header, 'RADIUS')

ucomp_write_iquv_image, data, l1_basename, file.wave_region, file.wavelengths, $
                        occulter_radius=occulter_radius, $
                        run=run

obj_destroy, file
obj_destroy, run

end
