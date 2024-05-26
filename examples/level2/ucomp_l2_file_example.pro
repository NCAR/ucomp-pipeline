; main-level example program

date = '20240409'

config_basename = 'ucomp.4-term.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

l0_basename = '20240409.180747.31.ucomp.1074.l0.fts'

l0_filename = filepath(l0_basename, $
                       subdir=[date], $
                       root=run->config('raw/basedir'))

file = ucomp_file(l0_filename, run=run)
file->update, 'level1'

ucomp_l2_file, file.l1_filename, run=run

; average_basename = '20240409.ucomp.1074.l1.synoptic.mean.fts'
; average_filename = filepath(average_basename, $
;                             subdir=[date, 'level2'], $
;                             root=run->config('processing/basedir'))
; ucomp_l2_file, average_filename, run=run

obj_destroy, run

end
