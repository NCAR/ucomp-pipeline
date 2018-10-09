; docformat = 'rst'

;+
; Convert an HST datetime to UT.
;
; :Params:
;   hst_date : in, required, type=string
;     HST date in the form 'YYYYMMDD'
;   hst_time : in, required, type=string
;     HST time in the form 'HHMMSS'
;
; :Keywords:
;   ut_date : out, optional, type=string
;     set to a named variable to retrieve the UT date in the form 'YYYYMMDD'
;   ut_time : out, optional, type=string
;     set to a named variable to retrieve the UT time in the form 'HHMMSS'
;-
pro ucomp_hst2ut, hst_date, hst_time, ut_date=ut_date, ut_time=ut_time
  compile_opt strictarr

  ymd = long(ucomp_decompose_date(hst_date))
  hms = long(ucomp_decompose_time(hst_time))

  jd = julday(ymd[1], ymd[2], ymd[0], hms[0], hms[1], hms[2])

  jd += 10.0D / 24.0D   ; UT is 10 hours ahead of HST

  caldat, jd, ut_month, ut_day, ut_year, ut_hours, ut_minutes, ut_seconds

  rounded_seconds = round(ut_seconds)
  if (rounded_seconds gt 59) then begin
    ; If ut_seconds rounds up like 59.995 would, then it should not be 60, but
    ; be 0 and 1 minute added which can cause all the other values to change if
    ; it was at the end of an hour, day, month, year. Instead, just add a
    ; second, recompute, and round down.
    ;
    ; This does not seem to happen in practice because CALDAT adds 1e-12 days,
    ; i.e., about 8.6e-8 seconds, so the rounding is always down if an integer
    ; number of seconds is given to start with.
    caldat, jd + 1.0D / 24.0D / 60.0D / 60.0D, $
            ut_month, ut_day, ut_year, ut_hours, ut_minutes, ut_seconds
    ut_seconds = floor(ut_seconds)
  endif else ut_seconds = rounded_seconds

  ut_date = string(ut_year, ut_month, ut_day, format='(%"%04d%02d%02d")')
  ut_time = string(ut_hours, ut_minutes, ut_seconds, format='(%"%02d%02d%02d")')
end
