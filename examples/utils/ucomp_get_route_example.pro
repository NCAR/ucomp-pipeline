; main-level example

dates = ['20130507', '20180107']
routing_file = filepath('ucomp.raw-routing.cfg', $
                        subdir=['..', 'config'], $
                        root=mg_src_root())
config_filename = filepath('ucomp.mgalloy.elliana.latest.cfg', $
                           subdir=['..', 'config'], $
                           root=mg_src_root())
for d = 0L, n_elements(dates) - 1L do begin
  ;print, dates[d], ucomp_get_route(routing_file, dates[d], found=found), $
  ;       format='(%"%s -> %s")'
  run = ucomp_run(dates[d], 'eod', config_filename)
  print, dates[d], run->config('raw/basedir'), $
         format='(%"%s -> %s")'
  obj_destroy, run
endfor

end
