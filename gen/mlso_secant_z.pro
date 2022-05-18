; docformat = 'rst'

;+
; Convert Julian Day to centuries since J2000.0.
;-
function calcTimeJulianCent,jd
  compile_opt strictarr

  return,(jd - 2451545.0D) / 36525.0D
end


;+
; Convert centuries since J2000.0 to Julian Day.	
;-
function calcJDFromJulianCent, t
  compile_opt strictarr

  return, t * 36525.0D + 2451545.0D
end

FUNCTION calcMeanObliquityOfEcliptic,t
;calculate the mean obliquity of the ecliptic (in degrees)
  seconds = 21.448d - double(t)*(46.8150d + double(t)*(0.00059d - double(t)*(0.001813d))) 
  e0 = 23.0d + (26.0d + (seconds/60.0d))/60.0d 
  return,e0
END 

FUNCTION calcObliquityCorrection,t
;calculate the corrected obliquity of the ecliptic (in degrees)
  e0 = calcMeanObliquityOfEcliptic(double(t)) 
  omega = 125.04d - 1934.136d * double(t) 
  e = e0 + 0.00256d * cos(((!dpi/180.0d)*omega)) 
  return,e
END 


FUNCTION calcGeomMeanLongSun,t
;calculate the Geometric Mean Longitude of the Sun (in degrees)
  L0 = (280.46646d + double(t) * (36000.76983d + 0.0003032d * double(t)))
  WHILE (l0 GT 360.0d) DO l0 = l0-360.0d
  WHILE (l0 LT 0.0d) DO l0 = l0+360.0d
  return,l0
END 


FUNCTION calcEccentricityEarthOrbit,t
;calculate the eccentricity of earth's orbit (unitless)
  e = 0.016708634d - double(t) * (0.000042037d + 0.0000001267d * double(t)) 
  return, e
END


FUNCTION calcGeomMeanAnomalySun,t
;calculate the Geometric Mean Anomaly of the Sun (in degrees)
  M = 357.52911d + double(t) * (35999.05029d - 0.0001537d * double(t))
  return,m
END 


;calculate the difference between true solar time and mean solar time
;(output: equation of time in minutes of time)	
function calcEquationOfTime, t
  compile_opt strictarr

  epsilon = calcObliquityCorrection(double(t)) 
  l0 = calcGeomMeanLongSun(double(t)) 
  e = calcEccentricityEarthOrbit(double(t)) 
  m = calcGeomMeanAnomalySun(double(t)) 
  y = tan(((!dpi/180.0d)*epsilon)/2.0d) 
  y = y * y
  sin2l0 = sin(2.0d * ((!dpi/180.0d)*l0)) 
  sinm   = sin(((!dpi/180.0d)*m)) 
  cos2l0 = cos(2.0d * ((!dpi/180.0d)*l0)) 
  sin4l0 = sin(4.0d * ((!dpi/180.0d)*l0))
  sin2m  = sin(2.0d * ((!dpi/180.0d)*m))
  Etime = y * sin2l0 - 2.0d * e * sinm + 4.0d * e * y * sinm * cos2l0 - 0.5d * y * y * sin4l0 - 1.25d * e * e * sin2m
  return,(180.0d/!dpi)*Etime*4.0d
end 

FUNCTION calcSunEqOfCenter,t
;calculate the equation of center for the sun (in degrees)
  m = double(calcGeomMeanAnomalySun(t))
  mrad = (!dpi/180.0d)*m
  sinm = sin(mrad) 
  sin2m = sin(mrad+mrad) 
  sin3m = sin(mrad+mrad+mrad)
  C = sinm * (1.914602d - double(t) * (0.004817d + 0.000014d * double(t))) + sin2m * (0.019993d - 0.000101d * double(t)) + sin3m * 0.000289d 
  return,c
END

FUNCTION calcSunTrueLong,t
;calculate the true longitude of the sun (in degrees)
  l0 = calcGeomMeanLongSun(double(t))
  c = calcSunEqOfCenter(double(t))
  O = l0 + c               
  return,O
END

FUNCTION calcSunApparentLong,t
;calculate the apparent longitude of the sun (in degrees)
  o = calcSunTrueLong(double(t))
  omega = 125.04d - 1934.136d * double(t) 
  lambda = o - 0.00569d - 0.00478d * sin(((!dpi/180.0d)*omega)) 
  return,lambda
END 

function calcSunDeclination, t
;calculate the declination of the sun (in degrees)
  e = calcObliquityCorrection(double(t)) 
  lambda = calcSunApparentLong(double(t)) 
  sint = sin(((!dpi/180.0d)*e)) * sin(((!dpi/180.0d)*lambda)) 
  theta = (180.0d/!dpi)*(asin(sint))
  return,theta
end 


function calcSolNoonUTC,jd, longitude
;calculate time of solar noon the given day at the given location on earth
;(in minute since 0 UTC)
  t = calcTimeJulianCent(double(JD))
  newt = calcTimeJulianCent(calcJDFromJulianCent(double(t)) + 0.5d + double(longitude)/360.0d) 
  eqTime = calcEquationOfTime(double(newt)) 
  solarNoonDec = calcSunDeclination(double(newt)) 
  solNoonUTC = 720.0d + (double(longitude) * 4.0d) - eqTime 
  return,solnoonutc
end 


;+
; Compute the secant Z.
;
; :Returns:
;   `float`/`fltarr`
;
; :Params:
;   true_dec : in, required, type=float/fltarr
;     true declination
;   jd : in, required, type=float/fltarr
;     Julian day
;   hour_angle : in, required, type=float/fltarr

;-
function mlso_secant_z, true_dec, jd, obsday_hours
  compile_opt strictarr

  mlso_lat =   19.535506D * !dtor
  mlso_lon = -155.576587D * !dtor
  ;solar_noon = calcSolNoonUTC(jd, mlso_lon)
  ;solar_noon = 22.161 * 60.0D
  solar_noon = 22.27638889D * 60.0D
  _true_dec = true_dec * !dtor

  ; the solar hour angle is an expression of time, expressed in angular
  ; measurement, from solar noon; at solar noon the hour angle is zero degrees,
  ; with the time before solar noon expressed as negative degrees, and the
  ; local time after solar noon expressed as positive degrees
  ;if (solar_noon lt 5.0 * 60.0) then solar_noon += 24.0D
  hour_angle = (obsday_hours + 10.0D - solar_noon / 60.0D) * (360.0D / 24.0)
  print, solar_noon, hour_angle
  hour_angle *= !dtor

  sec_z = 1.0D / (sin(mlso_lat) * sin(_true_dec) + cos(mlso_lat) * cos(_true_dec) * cos(hour_angle))
  return, sec_z
end


; main-level example

ut_datetime = '20211213.190812'

ut_date = strmid(ut_datetime, 0, 8)
ut_time = strmid(ut_datetime, 9, 6)
ucomp_ut2hst, ut_date, ut_time, hst_hours=obsday_hours

date_parts = long(ucomp_decompose_date(ut_date))
time_parts = long(ucomp_decompose_time(ut_time))

jd = julday(date_parts[1], date_parts[2], date_parts[0], $
            time_parts[0], time_parts[1], time_parts[2])

; from Steve's result for 20211213.190812.ucomp.1074.l1.5.fts
standard = 2.09741

hours = ucomp_decompose_time(ut_time, /float)
sun, date_parts[0], date_parts[1], date_parts[2], hours, $
     true_dec=true_dec
print, mlso_secant_z(true_dec, jd, obsday_hours), format='(%"computed sec(Z): %0.3f")'
print, standard, format='(%"standard sec(Z): %0.3f")'

end
