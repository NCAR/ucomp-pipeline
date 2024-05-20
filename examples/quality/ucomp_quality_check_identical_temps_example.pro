; main-level example program

;date = '20210620'
;date = '20210614'
date = '20211107'
;raw_basename = '20210620.202929.96.ucomp.1074.l0.fts'
;raw_basename = '20210615.011912.16.ucomp.1074.l0.fts'
raw_basename = '20211107.192028.35.ucomp.1074.l0.fts'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())

print, config_filename
run = ucomp_run(date, 'test', config_filename)

raw_filename = filepath(raw_basename, subdir=date, root=run->config('raw/basedir'))
file = ucomp_file(raw_filename, run=run)

file.quality = ucomp_quality_check_identical_temps(file)
print, file.gbu, format='(%"Quality: %d")'

obj_destroy, run

end
