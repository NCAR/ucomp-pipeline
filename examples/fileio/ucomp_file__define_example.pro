; main-level example program

;date = '20180101'
date = '20220415'

;f = '/hao/mahidata1/Data/CoMP/raw/20180101/20180101.164431.FTS'
f = '/hao/dawn/Data/UCoMP/incoming/20220415/20220416.054151.99.ucomp.l0.fts'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, subdir=['..', '..', 'config'], root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

file = ucomp_file(f, run=run)

obj_destroy, run

end
