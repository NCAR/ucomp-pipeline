; main-level example program

date = '20240409'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'test', config_filename)

raw_basename = '20240409.195647.32.ucomp.1074.l0.fts'
raw_filename = filepath(raw_basename, $
                        subdir=date, $
                        root=run->config('raw/basedir'))
ucomp_read_raw_data, raw_filename, $
                     primary_header=primary_header, $
                     ext_data=data, $
                     ext_headers=headers, $
                     repair_routine=run->epoch('raw_data_repair_routine'), $
                     badframes=run.badframes, $
                     all_zero=all_zero, $
                     logger=run.logger_name

file = ucomp_file(raw_filename, run=run)

step_number = 1L
ucomp_l1_step, 'ucomp_l1_average_data', $
               file, primary_header, data, headers, step_number=step_number, run=run

obj_destroy, [file, run]

end
