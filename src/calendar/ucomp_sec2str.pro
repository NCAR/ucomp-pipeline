; docformat = 'rst'

;+
; Return a human readable string for a number of seconds.
;
; :Returns:
;   string
;
; :Examples:
;   For example::
;
;     IDL> print, comp_sec2str(3 * 60L * 60L * 24L + 2 * 60 * 60 + 1 * 60 + 2)
;     3 days 2 hrs 1 min 2 secs
;
; :Params:
;   secs : in, required, type=numeric scalar
;     number of seconds in time interval
;-
function ucomp_sec2str, secs
  compile_opt strictarr

  if (n_elements(secs) eq 0L || ~finite(secs)) then begin
    return, 'unknown time'
  endif

  _secs = long(secs)
  intervals = [{name: 'days', secs: 60L * 60L * 24L}, $
               {name: 'hrs', secs: 60L * 60L}, $
               {name: 'mins', secs: 60L}, $
               {name: 'secs', secs: 1L}]
  result = strarr(n_elements(intervals))

  for i = 0L, n_elements(intervals) - 1L do begin
    value = _secs / intervals[i].secs
    if (value gt 0L) then begin
      _secs -= value * intervals[i].secs
      name = intervals[i].name
      if (value eq 1) then name = strmid(name, 0, strlen(name) - 1)
      result[i] = string(value, name, format='(%"%d %s")')
    endif
  endfor

  ind = result[where(result ne '', count, /null)]
  return, secs ge 60.0 $
            ? strjoin(ind, ' ') $
            : string(secs, format='(%"%0.1f secs")')
end
