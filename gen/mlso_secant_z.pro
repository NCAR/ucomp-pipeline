; docformat = 'rst'


;+
; Compute the secant Z.
;
; :Returns:
;   `float`/`fltarr`
;
; :Params:
;   jd : in, required, type=float/fltarr
;     Julian day
;
; :Keywords:
;   sidereal_time : out, optional, type=float
;     set to a named variable to retrieve sidereal time in GMST day fraction
;-
function mlso_secant_z, jd, sidereal_time=gmst_sidereal_time
  compile_opt strictarr

  mlso_lat =    19.535506D * !dtor
  mlso_lon = - 155.576587D * !dtor

  ; need sidereal time
  ephem2, jd, sol_ra, sol_dec, b0, p, semi_diam, gmst_sidereal_time, dist, xsun, ysun, zsun

  sidereal_time = gmst_sidereal_time * 2.0D * !dpi + mlso_lon

  ; convert variables degrees to radians
  sol_dec  = sol_dec * !dtor
  sol_ra   = sol_ra * !dtor

  hour_angle = sidereal_time - sol_ra

  ; the solar hour angle is an expression of time, expressed in angular
  ; measurement, from solar noon; at solar noon the hour angle is zero degrees,
  ; with the time before solar noon expressed as negative degrees, and the
  ; local time after solar noon expressed as positive degrees

  sec_z = 1.0D / (sin(mlso_lat) * sin(sol_dec) + cos(mlso_lat) * cos(sol_dec) * cos(hour_angle))

  return, sec_z
end


; main-level example

ut_datetime = '20211213.190812'

ut_date = strmid(ut_datetime, 0, 8)
ut_time = strmid(ut_datetime, 9, 6)

date_parts = long(ucomp_decompose_date(ut_date))
time_parts = long(ucomp_decompose_time(ut_time))

jd = julday(date_parts[1], date_parts[2], date_parts[0], $
            time_parts[0], time_parts[1], time_parts[2])
print, jd, format='(%"%0.6f")'
print, mlso_secant_z(jd), format='(%"computed sec(Z): %0.3f")'

; from Steve's result for 20211213.190812.ucomp.1074.l1.5.fts
standard = 2.09741
print, standard, format='(%"standard sec(Z): %0.3f")'

end
