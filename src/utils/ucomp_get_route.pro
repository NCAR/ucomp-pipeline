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
;
; :Keywords:
;   found : out, optional, type=boolean
;     set to a named variable to retrieve whether a route was found
;-
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
