; main-level example program

;date = '20220105'
date = '20220209'
;date = '20220214'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)
ucomp_memory_plot, run=run
obj_destroy, run

end
