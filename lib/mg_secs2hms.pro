; docformat = 'rst'

;+
; Convert a number of seconds to hours, minutes, and seconds.
;
; :Returns:
;   string
;
; :Params:
;   secs : in, required, type=float/integer
;     number of seconds
;
; :Keywords:
;   format : in, optional, type=string, default='%d:%02d:%4.1f'
;     C-style format string for hours, minutes, seconds
;-
function mg_secs2hms, secs, format=format
  compile_opt strictarr

  _format = mg_default(format, '%d:%02d:%4.1f')
  _format = '(%"' + _format + '")'

  hours = long(secs) / 60L / 60L
  minutes = long(secs) / 60L - hours * 60L
  seconds = secs - hours * 60L * 60L - minutes * 60L

  return, string(hours, minutes, seconds, format=_format)
end
