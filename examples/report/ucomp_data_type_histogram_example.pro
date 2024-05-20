; main-level example program

date = '20210312'
config_filename = filepath('ucomp.latest.cfg', $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'eod', config_filename, /no_log)
run->make_raw_inventory

engineering_basedir = run->config('engineering/basedir')
output_filename = filepath(string(run.date, $
                                  format='(%"%s.ucomp.data_types.png")'), $
                           subdir=ucomp_decompose_date(run.date), $
                           root=engineering_basedir)
ucomp_data_type_histogram, output_filename, $
                           run=run
obj_destroy, run

end
