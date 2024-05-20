; main-level program

date = '20221125'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

basename = '20221126.004426.ucomp.1074.l1.p3.intensity.gif'
processing_basedir = run->config('processing/basedir')
filename = filepath(basename, subdir=[date, 'level1'], root=processing_basedir)

read_gif, filename, im, r, g, b

device, decomposed=0
tvlct, r, g, b
mg_image, im, /new, title=basename

dims = size(im, /dimensions)
rsun = 325.37
field_radius = run->epoch('field_radius')
ucomp_grid, rsun, field_radius, (dims[0:1] - 1.0) / 2.0, color=250

obj_destroy, run

end
