; docformat = 'rst'

;+
; Convert a DATE-OBS string to a "YYYYMMDD.HHMMSS" string.
;
; :Returns:
;   string
;
; :Params:
;   dateobs : in, required, type=string
;     DATE-OBS string like "2020-05-09T00:45:03.04" or "2020-05-09"
;-
function ucomp_dateobs2datetime, dateobs
  compile_opt strictarr

  ut_year   = strmid(dateobs, 0, 4)
  ut_month  = strmid(dateobs, 5, 2)
  ut_day    = strmid(dateobs, 8, 2)

  ut_hour   = strmid(dateobs, 11, 2)
  ut_minute = strmid(dateobs, 14, 2)
  ut_second = strmid(dateobs, 17, 2)

  return, string(ut_year, ut_month, ut_day, ut_hour, ut_minute, ut_second, $
                 format='%s%s%s.%s%s%s')
end
