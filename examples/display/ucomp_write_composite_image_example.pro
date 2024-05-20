; main-level example program

;date = '20211003'
date = '20240409'

config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

wave_regions = ['1074', '789', '637']
mean_basenames = date + '.ucomp.' + wave_regions + '.l1.synoptic.mean.fts'
mean_filenames = filepath(mean_basenames, $
                          subdir=[date, 'level2'], $
                          root=run->config('processing/basedir'))
ucomp_write_composite_image, mean_filenames, run=run
ucomp_write_composite_image, mean_filenames, /thumbnail, run=run

; wave_regions = ['706', '1074', '789']
; mean_basenames = date + '.ucomp.' + wave_regions + '.l1.synoptic.mean.fts'
; mean_filenames = filepath(mean_basenames, $
;                           subdir=[date, 'level2'], $
;                           root=run->config('processing/basedir'))
; ucomp_write_composite_image, mean_filenames, run=run

obj_destroy, run

end
