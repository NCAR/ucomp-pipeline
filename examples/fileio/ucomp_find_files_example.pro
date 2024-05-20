; main-level example program

date = '20221125'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

files = ucomp_find_files('level1', wave_region='530', count=count, run=run)

help, files, count
print, files

obj_destroy, run

end
