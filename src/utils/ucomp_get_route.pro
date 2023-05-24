; docformat = 'rst'

;+
; Get the basedir from a routing file for a given date.
;
; :Returns:
;   string, or `!null` if not found
;
; :Params:
;   routing_file : in, required, type=string
;     filename of a routing file
;   date : in, required, type=string
;     date in the form "YYYYMMDD"
;   type : in, required, type=string
;     type of routine to get, i.e., "raw" or "process"
;
; :Keywords:
;   found : out, optional, type=boolean
;     set to a named variable to retrieve whether a route was found
;-
function ucomp_get_route, routing_file, date, type, found=found
  compile_opt strictarr

  case strlowcase(type) of
    'raw': section = 'ucomp-raw'
    'process': section = 'ucomp-process'
    else: message, string(type, format='(%"unknown type: %s")')
  endcase

  config = mg_read_config(routing_file)
  date_specs = config->options(section=section, count=n_date_specs)

  for s = 0L, n_date_specs - 1L do begin
    if (strmatch(date, date_specs[s])) then begin
      route = config->get(date_specs[s], section=section)
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
