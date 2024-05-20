; main-level example program

date = '20210312'
config_filename = filepath('ucomp.production.cfg', $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'eod', config_filename, /no_log)
run->make_raw_inventory

engineering_basedir = run->config('engineering/basedir')
ucomp_wave_region_histogram, filepath(string(run.date, $
                                             format='(%"%s.ucomp.daily.wave_regions.png")'), $
                                      subdir=ucomp_decompose_date(run.date), $
                                      root=engineering_basedir), $
                             run=run
obj_destroy, run

end
