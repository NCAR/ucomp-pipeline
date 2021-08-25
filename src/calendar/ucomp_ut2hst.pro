; docformat = 'rst'

;+
; Convert an HST datetime to UT.
;
; :Params:
;   ut_date : in, required, type=string
;     UT date in the form 'YYYYMMDD'
;   ut_time : in, required, type=string
;     UT time in the form 'HHMMSS'
;
; :Keywords:
;   hst_date : out, optional, type=string
;     set to a named variable to retrieve the HST date in the form 'YYYYMMDD'
;   hst_time : out, optional, type=string
;     set to a named variable to retrieve the HST time in the form 'HHMMSS'
;   hst_hours : out, optional, type=float
;    set to named variable to retrieve the decimal hours into the HST day
;-
pro ucomp_ut2hst, ut_date, ut_time, $
                  hst_date=hst_date, hst_time=hst_time, hst_hours=hst_hours
  compile_opt strictarr

  ymd = long(ucomp_decompose_date(ut_date))
  hms = long(ucomp_decompose_time(ut_time))

  jd = julday(ymd[1], ymd[2], ymd[0], hms[0], hms[1], hms[2])

  jd -= 10.0D / 24.0D   ; UT is 10 hours ahead of HST

  caldat, jd, hst_month, hst_day, hst_year, hst_hours, hst_minutes, hst_seconds

  rounded_seconds = round(hst_seconds)
  if (rounded_seconds gt 59) then begin
    ; If hst_seconds rounds up like 59.995 would, then it should not be 60, but
    ; be 0 and 1 minute added which can cause all the other values to change if
    ; it was at the end of an hour, day, month, year. Instead, just add a
    ; second, recompute, and round down.
    ;
    ; This does not seem to happen in practice because CALDAT adds 1e-12 days,
    ; i.e., about 8.6e-8 seconds, so the rounding is always down if an integer
    ; number of seconds is given to start with.
    caldat, jd + 1.0D / 24.0D / 60.0D / 60.0D, $
            hst_month, hst_day, hst_year, hst_hours, hst_minutes, hst_seconds
    hst_seconds = floor(hst_seconds)
  endif else hst_seconds = rounded_seconds

  hst_date = string(hst_year, hst_month, hst_day, format='(%"%04d%02d%02d")')
  hst_time = string(hst_hours, hst_minutes, hst_seconds, format='(%"%02d%02d%02d")')
  hst_hours = hst_hours + hst_minutes / 60.0 + hst_seconds / 60.0 / 60.0
end
