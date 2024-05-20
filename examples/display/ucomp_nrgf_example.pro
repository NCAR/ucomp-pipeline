; main-level example program

date = '20220118'
config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'example', config_filename)

basename = '20220118.223347.ucomp.1074.l1.5.fts'

filename = filepath(basename, subdir=[date, 'level1'], root=run->config('processing/basedir'))
fits_open, filename, fcb
fits_read, fcb, primary_data, primary_header, exten_no=0
fits_read, fcb, data, header, exten_no=3
fits_close, fcb

obj_destroy, run

occulter_radius = ucomp_getpar(primary_header, 'RADIUS')

intensity_im = data[*, *, 0]
nrgf_intensity_im = ucomp_nrgf(intensity_im, occulter_radius, $
                               mean_profile=mean_profile, $
                               stddev_profile=stddev_profile)

device, decomposed=0
gamma_ct, 0.7
loadct, 0

mg_image, bytscl(intensity_im, 0.0, 35.0), /new
mg_image, bytscl(nrgf_intensity_im^0.7, 0.0, 3.0), /new

window, xsize=800, ysize=300, title='Mean profile', /free
plot, mean_profile, yrange=[0.0, 20.0], ystyle=1
window, xsize=800, ysize=300, title='Std dev profile', /free
plot, stddev_profile, yrange=[0.0, 20.0], ystyle=1

end
