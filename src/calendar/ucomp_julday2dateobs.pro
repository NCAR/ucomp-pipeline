; docformat = 'rst'

;+
; Convert a Julian date into DATE-OBS string of the form "YYYY-MM-DDTHH:MM:SSZ"
;
; :Returns:
;   string
;
; :Params:
;   jd : in, required, type=double
;     Julian date
;-
function ucomp_julday2dateobs, jd
  compile_opt strictarr

  caldat, jd, month, day, year, hours, minutes, seconds

  return, string(year, month, day, hours, minutes, seconds, $
                 format='%04d-%02d-%02dT%02d:%02d:%02dZ')
end
