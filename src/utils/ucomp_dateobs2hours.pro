; docformat = 'rst'

;+
; Convert a DATE-OBS string into decimal hours into the observing day.
;
; :Returns:
;   float
;
; :Params:
;   dateobs : in, required, type=string
;     DATE-OBS string like "2020-05-09T00:45:03.04"
;-
function ucomp_dateobs2hours, dateobs
  compile_opt strictarr

  ut_year   = strmid(dateobs, 0, 4)
  ut_month  = strmid(dateobs, 5, 2)
  ut_day    = strmid(dateobs, 8, 2)

  ut_hour   = strmid(dateobs, 11, 2)
  ut_minute = strmid(dateobs, 14, 2)
  ut_second = strmid(dateobs, 17, 2)

  ut_date = ut_year + ut_month + ut_day
  ut_time = ut_hour + ut_minute + ut_second

  ucomp_ut2hst, ut_date, ut_time, hst_hours=hst_hours

  return, hst_hours
end
