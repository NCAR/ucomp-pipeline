
function get_sun, item, et=et, lon=lon, $
  dist=dist, true_long=true_long, app_long=app_long, $
  true_lat=true_lat, app_lat=app_lat, sd=sd, $
  true_ra=true_ra, app_ra=app_ra, true_dec=true_dec, $
  app_dec=app_dec, pa=pa, he_lon=he_lon, he_lat=he_lat, $
  carr=carr, help=help, list=list, qs=qs

;+
; NAME:
;       GET_SUN
; PURPOSE:
;	Provides geocentric physical ephemeris of the sun.
;       Front end to routine SUN to provide 'Yohkoh-style' time interface
; CATEGORY:
;
; CALLING SEQUENCE:
;       OUT = GET_SUN(ITEM)
; INPUTS:
;       ITEM -	Reference time for ephemeris data.  Interpreted as
;	  an ephemeris time (ET).  The difference between ephemeris
;	  time and universal time (Delta T = ET - UT) is not
;	  completely predictable but is about 1 minute now.  This
;	  difference is noticable slightly.  The form can be:
;           (1) structure with a .time and .day field,
;           (2) standard 7-element external representation, or
;	    (3) a string of the format "hh:mm dd-mmm-yy".
;         If no date is entered, the current date is used.
;         The year is not required, but if entered should be
;         of the form "dd-mmm" style.  The date should be entered
;         in string style with date first.
; KEYWORD INPUTS:
;      /LIST :	Displays values on screen.
; OUTPUTS:
;	DATA = Vector of solar ephemeris data:
;	  DATA( 0) = Distance (AU).
;	  DATA( 1) = Semidiameter of disk (sec).
;	  DATA( 2) = True longitude (deg).
;	  DATA( 3) = True latitude (0 always).
;	  DATA( 4) = Apparent longitude (deg).
;	  DATA( 5) = Apparent latitude (0 always).
;	  DATA( 6) = True RA (hours).
;	  DATA( 7) = True Dec (deg).
;	  DATA( 8) = Apparent RA (hours).
;	  DATA( 9) = Apparent Dec (deg).
;	  DATA(10) = Longitude at center of disk (deg).
;	  DATA(11) = Latitude at center of disk (deg).
;	  DATA(12) = Position angle of rotation axis (deg).
;	  DATA(13) = decimal carrington rotation number.
; KEYWORD OUTPUTS
;	DIST 		= Distance in AU.
;	SD 		= Semidiameter of disk in arc seconds.
;	TRUE_LONG	= True longitude (deg).
;	TRUE_LAT 	= 0 always.
;	APP_LONG 	= Apparent longitude (deg).
;	APP_LAT 	= 0 always.
;	TRUE_RA 	= True RA (hours).
;	TRUE_DEC 	= True Dec (deg).
;	APP_RA 		= Apparent RA (hours).
;	APP_DEC 	= Apparent Dec (deg).
;	HE_LON 		= Longitude at center of disk (deg).
;	HE_LAT 		= Latitude at center of disk (deg).
;	PA 		= Position angle of rotation axis (deg).
;	CARR		= decimal carrington rotation number.
; COMMON BLOCKS:
; NOTES:
;       Notes: based on the book Astronomical Formulae
;         for Calculators, by Jean Meeus.
;         If no arguments given will prompt and list values.
; MODIFICATION HISTORY:
;	Feb, 1994 - GLS - Written to provide 'Yohkoh style' time
;	  interface to routine SUN.PRO by R. Sterner, 19 Feb, 1991
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
  np = n_params(0)
 
  if keyword_set(help) then begin
    print,' Computes geocentric physical ephemeris of the sun.'
    print,' Calling seqence: CARR = GET_CARR(ITEM)'
    print,'   ITEM is interpreted as an ephemeris time (ET)'
    print,'   The difference between ephemeris time and
    print,'   universal time (Delta T = ET - UT) is not completely'
    print,'   predictable but is about 1 minute now.'
    print,'   This difference is noticable slightly.'
    print,' Keywords:'
    print,'  /LIST displays values on screen.'
    print,'   DIST 	= distance in AU.'
    print,'   SD 	= semidiameter of disk in arc seconds.'
    print,'   TRUE_LONG = true longitude (deg).'
    print,'   TRUE_LAT 	= 0 always.'
    print,'   APP_LONG 	= apparent longitude (deg).'
    print,'   APP_LAT 	= 0 always.'
    print,'   TRUE_RA 	= true RA (hours).'
    print,'   TRUE_DEC 	= true Dec (deg).'
    print,'   APP_RA 	= apparent RA (hours).'
    print,'   APP_DEC 	= apparent Dec (deg).
    print,'   HE_LAT 	= latitude at center of disk (deg).'
    print,'   HE_LON 	= longitude at center of disk (deg).'
    print,'   PA 	= position angle of rotation axis (deg).'
    print,'   CARR 	= decimal Carrinton rotation number (deg).'
    print,' Method: based on the book Astronomical Formulae'
    print,'   for Calculators, by Jean Meeus.'
    print,'   If no arguments given will prompt and list values.'
    return, ''
  endif
 
; Julian date:
  jd = double(tim2jd(item))

; Julian Centuries from 1900.0:
  t = (jd - 2415020d)/36525d

; Carrington Rotation Number:
  carr = (1./27.2753D0)*(jd-2398167.d0) + 1.d0

; Geometric Mean Longitude (deg):
  mnl = 279.69668d0 + 36000.76892d0*t + 0.0003025*t^2
  mnl = mnl mod 360d0

; Mean anomaly (deg):
  mna = 358.47583d0 + 35999.04975d0*t - $
        0.000150d0*t^2 - 0.0000033d0*t^3
  mna = mna mod 360d0

; Eccentricity of orbit:
  e = 0.01675104d0 - 0.0000418d0*t - 0.000000126d0*t^2

; Sun's equation of center (deg):
  c = (1.919460d0 - 0.004789d0*t - 0.000014d0*t^2)*sin(mna/!radeg) + $
      (0.020094d0 - 0.000100d0*t)*sin(2*mna/!radeg) + $
      0.000293d0*sin(3*mna/!radeg)

; Sun's true geometric longitude (deg)
;   (Refered to the mean equinox of date.  Question: Should the higher
;    accuracy terms from which app_long is derived be added to true_long?)
  true_long = (mnl + c) mod 360d0

; Sun's true anomaly (deg):
  ta = (mna + c) mod 360d0

; Sun's radius vector (AU).  There are a set of higher accuracy
;   terms not included here.  The values calculated here agree with
;   the example in the book:
  dist = 1.0000002d0*(1.d0 - e^2)/(1.d0 + e*cos(ta/!radeg))

; Semidiameter (arc sec):
  sd = 959.63/dist

; Apparent longitude (deg) from true longitude:
  omega = 259.18d0 - 1934.142d0*t		; Degrees
  app_long = true_long - 0.00569d0 - 0.00479d0*sin(omega/!radeg)

; Latitudes (deg) for completeness.  Never more than 1.2 arc sec from 0,
;   always set to 0 here:
  true_lat = fltarr(n_elements(dist))
  app_lat = fltarr(n_elements(dist))

; True Obliquity of the ecliptic (deg):
  ob1 = 23.452294d0 - 0.0130125d0*t - 0.00000164d0*t^2 $
        + 0.000000503d0*t^3

; True RA, Dec (is this correct?):
  y = cos(ob1/!radeg)*sin(true_long/!radeg)
  x = cos(true_long/!radeg)
  recpol, x, y, r, true_ra, /deg
  true_ra = true_ra mod 360d0
  neg_vals = where(true_ra lt 0,count)
  if count gt 0 then true_ra(neg_vals) = true_ra(neg_vals) + 360d0
  true_ra = true_ra/15d0
  true_dec = asin(sin(ob1/!radeg)*sin(true_long/!radeg))*!radeg

; Apparent  Obliquity of the ecliptic:
  ob2 = ob1 + 0.00256d0*cos(omega/!radeg)	; Correction.

; Apparent  RA, Dec (agrees with example in book):
  y = cos(ob2/!radeg)*sin(app_long/!radeg)
  x = cos(app_long/!radeg)
  recpol, x, y, r, app_ra, /deg
  app_ra = app_ra mod 360d0
  neg_vals = where(app_ra lt 0,count)
  if count gt 0 then app_ra(neg_vals) = app_ra(neg_vals) + 360d0
  app_ra = app_ra/15d0
  app_dec = asin(sin(ob2/!radeg)*sin(app_long/!radeg))*!radeg

; Heliographic coordinates:
  theta = (jd - 2398220d0)*360d0/25.38d0	; Deg.
  i = 7.25					; Deg.
  k = 74.3646 + 1.395833*t			; Deg.
  lamda = true_long - 0.00569d0
  lamda2 = lamda - 0.00479d0*sin(omega/!radeg)
  diff = (lamda - k)/!radeg
  x = atan(-cos(lamda2/!radeg)*tan(ob1/!radeg))*!radeg
  y = atan(-cos(diff)*tan(i/!radeg))*!radeg

; Position of north pole (deg):
  pa = x + y

; Latitude at center of disk (deg):
  he_lat = asin(sin(diff)*sin(i/!radeg))*!radeg

; Longitude at center of disk (deg):
  y = -sin(diff)*cos(i/!radeg)
  x = -cos(diff)
  recpol, x, y, r, eta, /deg
  he_lon = (eta - theta) mod 360d0
  neg_vals = where(he_lon lt 0,count)
  if count gt 0 then he_lon(neg_vals) = he_lon(neg_vals) + 360d0

; List values:
  if keyword_set(list) then begin
    print,' '
    print,' Solar Ephemeris for ' + fmt_tim(item)
    print,' '
    print,' Distance (AU) = '+strtrim(dist,2)
    print,' Semidiameter (arc sec) = '+strtrim(sd,2)
    print,' True (long, lat) in degrees = ('+$
      strtrim(true_long,2)+', '+strtrim(true_lat,2)+')'
    print,' Apparent (long, lat) in degrees = ('+$
      strtrim(app_long,2)+', '+strtrim(app_lat,2)+')'
    print,' True (RA, Dec) in hrs, deg = ('+$
      strtrim(true_ra,2)+', '+strtrim(true_dec,2)+')'
    print,' Apparent (RA, Dec) in hrs, deg = ('+$
      strtrim(app_ra,2)+', '+strtrim(app_dec,2)+')'
    print,' Heliographic long. and lat. of disk center in deg = ('+$
      strtrim(he_lon,2)+', '+strtrim(he_lat,2)+')'
    print,' Position angle of north pole in deg = '+$
      strtrim(pa,2)
    print,' Carrington Rotation Number = '+$
      strtrim(carr,2)
    print,' '
  endif

  if n_elements(dist) eq 1 then $
    data = [dist,sd,true_long,true_lat,app_long,app_lat, $
	    true_ra,true_dec,app_ra,app_dec,he_lon,he_lat, $
	    pa,carr] else $
    data = transpose([[dist],[sd],[true_long],[true_lat],[app_long], $
		      [app_lat],[true_ra],[true_dec],[app_ra],[app_dec], $
		      [he_lon],[he_lat],[pa],[carr]])

  if keyword_set(qs) then stop

  return,data
  end

