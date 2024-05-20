; main-level example program

date = '20220227'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

raw_basename = '20220227.194855.73.ucomp.1074.l0.fts'
raw_filename = filepath(raw_basename, $
                        subdir=[date], $
                        root=run->config('raw/basedir'))
file = ucomp_file(raw_filename, run=run)

ucomp_read_raw_data, file.raw_filename, $
                     primary_header=primary_header, $
                     ext_data=ext_data, $
                     ext_headers=ext_headers, $
                     repair_routine=run->epoch('raw_data_repair_routine')

success = ucomp_quality_check_time_interval(file, $
                                            primary_header, $
                                            ext_data, $
                                            ext_headers, $
                                            run=run)
help, success

obj_destroy, file
obj_destroy, run

end
