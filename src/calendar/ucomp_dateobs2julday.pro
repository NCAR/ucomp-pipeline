; docformat = 'rst'

;+
; Convert a DATE-OBS string into Julidan date.
;
; :Returns:
;   double
;
; :Params:
;   dateobs : in, required, type=string
;     DATE-OBS string like "2020-05-09T00:45:03.04" or "2020-05-09"
;-
function ucomp_dateobs2julday, dateobs
  compile_opt strictarr

  ut_year   = float(strmid(dateobs, 0, 4))
  ut_month  = float(strmid(dateobs, 5, 2))
  ut_day    = float(strmid(dateobs, 8, 2))

  ut_hour   = float(strmid(dateobs, 11, 2))
  ut_minute = float(strmid(dateobs, 14, 2))
  ut_second = float(strmid(dateobs, 17, 2))

  jd = julday(ut_month, ut_day, ut_year, ut_hour, ut_minute, ut_second)

  return, jd
end
