; docformat = 'rst'

function ucomp_get_route, routing_file, date, found=found
  compile_opt strictarr

  config = mg_read_config(routing_file)
  date_specs = config->options(section='locations', count=n_date_specs)

  for s = 0L, n_date_specs - 1L do begin
    if (strmatch(date, date_specs[s])) then begin
      route = config->get(date_specs[s], section='locations')
      found = 1B
      return, route
    endif
  endfor

  found = 0B
  return, !null
end


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
