; main-level example program

date = '20220901'
config_basename = 'ucomp.publish.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

processing_basedir = run->config('processing/basedir')

ucomp_quicklooks_publish, run=run

obj_destroy, run

end
