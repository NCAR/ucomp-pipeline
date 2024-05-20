; main-level example program

; date = '20220302'
; date = '20220310'
date = '20220219'
; raw_basename = '20220302.211521.32.ucomp.l0.fts'
; raw_basename = '20220302.174547.40.ucomp.l0.fts'
; raw_basename = '20220310.180408.94.ucomp.1074.l0.fts'
raw_basename = '20220219.212350.63.ucomp.637.l0.fts'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

raw_basedir = run->config('raw/basedir')
raw_filename = filepath(raw_basename, subdir=date, root=raw_basedir)

ucomp_read_raw_data, raw_filename, $
                     primary_header=primary_header, $
                     ext_data=ext_data, $
                     ext_headers=ext_headers, $
                     repair_routine=run->epoch('raw_data_repair_routine'), $
                     badframes=run.badframes, $
                     all_zero=all_zero
print, raw_filename
print, raw_basename, all_zero ? 'YES' : 'NO', format='%s all zero: %s'

obj_destroy, run

end
