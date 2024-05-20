; main-level example

date = '20220226'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

; should not pass:
; raw_basename = '20220227.003322.77.ucomp.1074.l0.fts'

; should pass:
raw_basename = '20220227.025043.18.ucomp.1074.l0.fts'

raw_filename = filepath(raw_basename, $
                        subdir=[date], $
                        root=run->config('raw/basedir'))
file = ucomp_file(raw_filename, run=run)

ucomp_read_raw_data, file.raw_filename, $
                     primary_header=primary_header, $
                     ext_data=ext_data, $
                     ext_headers=ext_headers, $
                     repair_routine=run->epoch('raw_data_repair_routine')

success = ucomp_quality_wave_region(file, $
                                    primary_header, $
                                    ext_data, $
                                    ext_headers, $
                                    run=run)
print, success eq 0 ? 'YES' : 'NO', format='passed: %s'

obj_destroy, file
obj_destroy, run

end
