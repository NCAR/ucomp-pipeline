; docformat = 'rst'

;+
; Convert a date in the format saved in an IDL save file to the DATE-OBS
; format.
;
; :Returns:
;   date in the form "YYYY-MM-DDTHH:MM:SSZ"
;
; :Params:
;   d : in, required, type=string
;     date in the form stored in an IDL save file, e.g., "Tue Nov 15 14:05:53 2022"
;-
function ucomp_idlsave2dateobs, d
  compile_opt strictarr

  s = mg_strptime(strmid(d, 4), '%b %d %H:%M:%S %Y')
  return, string(s.year, s.month, s.day, s.hour, s.minute, s.second, $
                 format='%04d-%02d-%02dT%02d:%02d:%02dZ')
end


; main-level example

d = 'Tue Nov 15 14:05:53 2022'
print, d, ucomp_idlsave2dateobs(d), format='%s -> %s'

end
