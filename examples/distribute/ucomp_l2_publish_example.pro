; main-level example program

date = '20220901'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

; Note: this doesn't completely work outside the pipeline because it hasn't
; done the inventory, so individual time level 2 files won't be published.
ucomp_l2_publish, run=run

obj_destroy, run

end
