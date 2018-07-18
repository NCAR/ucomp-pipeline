;+
; Project     : SOHO - CDS     
;                   
; Name        : SUN_POS
;               
; Purpose     : Calculate solar ephemeris parameters.
;               
; Explanation : Allows for planetary and lunar perturbations in the calculation
;               of solar longitude at date and various other solar positional
;               parameters.
;               
; Use         : IDL> sun_pos, date, longitude, ra, dec, app_long, obliq
;    
; Inputs      : date - fractional number of days since JD 2415020.0 
;               
; Opt. Inputs : None
;               
; Outputs     : longitude  -  Longitude of sun for mean equinox of date (degs)
;               ra         -  Apparent RA for true equinox of date (degs)
;               dec        -  Apparent declination for true equinox of date (degs)
;               app_long   -  Apparent longitude (degs)
;               obliq      -  True obliquity (degs)
;               
; Opt. Outputs: All above
;               
; Keywords    : None
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, coords
;               
; Prev. Hist. : From Fortran routine by B Emerson (RGO).
;
; Written     : CDS/IDL version by C D Pike, RAL, 17-May-94
;               
; Modified    : 
;
; Version     : Version 1, 17-May-94
;-            

pro  sun_pos, dd, longmed, ra, dec, l, oblt

;
;  This routine is a truncated version of Newcomb's Sun and
;  is designed to give apparent angular coordinates (T.E.D) to a
;  precision of one second of time

;
;  form time in Julian centuries from 1900.0
;
t = dd/36525.0d0

;
;  form sun's mean longitude
;
l = (279.696678d0+((36000.768925d0*t) mod 360.0d0))*3600.0d0

;
;  allow for ellipticity of the orbit (equation of centre)
;  using the Earth's mean anomoly ME
;
me = 358.475844d0 + ((35999.049750D0*t) mod 360.0d0)
ellcor  = (6910.1d0 - 17.2D0*t)*sin(me*!dtor) + 72.3D0*sin(2.0D0*me*!dtor)
l = l + ellcor

;
; allow for the Venus perturbations using the mean anomaly of Venus MV
;
mv = 212.603219d0 + ((58517.803875d0*t) mod 360.0d0) 
vencorr = 4.8D0 * cos((299.1017d0 + mv - me)*!dtor) + $
          5.5D0 * cos((148.3133d0 +  2.0D0 * mv  -  2.0D0 * me )*!dtor) + $
          2.5D0 * cos((315.9433d0 +  2.0D0 * mv  -  3.0D0 * me )*!dtor) + $
          1.6D0 * cos((345.2533d0 +  3.0D0 * mv  -  4.0D0 * me )*!dtor) + $
          1.0D0 * cos((318.15d0   +  3.0D0 * mv  -  5.0D0 * me )*!dtor)
l = l + vencorr

;
;  Allow for the Mars perturbations using the mean anomaly of Mars MM
;
mm = 319.529425d0  +  (( 19139.858500d0 * t)  mod  360.0d0 )
marscorr = 2.0d0 * cos((343.8883d0 -  2.0d0 * mm  +  2.0d0 * me)*!dtor ) + $
           1.8D0 * cos((200.4017d0 -  2.0d0 * mm  + me) * !dtor)
l = l + marscorr

;
; Allow for the Jupiter perturbations using the mean anomaly of
; Jupiter MJ
;
mj = 225.328328d0  +  (( 3034.6920239d0 * t)  mod  360.0d0 )
jupcorr = 7.2d0 * cos(( 179.5317d0 - mj + me )*!dtor) + $
          2.6d0 * cos((263.2167d0  -  MJ ) *!dtor) + $
          2.7d0 * cos(( 87.1450d0  -  2.0d0 * mj  +  2.0D0 * me ) *!dtor) + $
          1.6d0 * cos((109.4933d0  -  2.0d0 * mj  +  me ) *!dtor)
l = l + jupcorr

;
; Allow for the Moons perturbations using the mean elongation of
; the Moon from the Sun D
;
d = 350.7376814d0  + (( 445267.11422d0 * t)  mod  360.0d0 )
mooncorr  = 6.5d0 * sin(d*!dtor)
l = l + mooncorr

;
; Allow for long period terms
;
longterm  = + 6.4d0 * sin(( 231.19d0  +  20.20d0 * t )*!dtor)
l  =    l + longterm
l  =  ( l + 2592000.0d0)  mod  1296000.0d0 
longmed = l/3600.0d0

;
; Allow for Aberration
;
l  =  l - 20.5d0

;
; Allow for Nutation using the longitude of the Moons mean node OMEGA
;
omega = 259.183275d0 - (( 1934.142008d0 * t ) mod 360.0d0 )
l  =  l - 17.2d0 * sin(omega*!dtor)

;
; Form the True Obliquity
;
oblt  = 23.452294d0 - 0.0130125d0*t + (9.2d0*cos(omega*!dtor))/3600.0d0

;
; Form Right Ascension and Declination
;
l = l/3600.0d0
ra  = atan( sin(l*!dtor) * cos(oblt*!dtor) , cos(l*!dtor) ) * !radeg

if (ra lt 0.0d0) then  ra = ra + 360.0d0

dec = asin(sin(l*!dtor) * sin(oblt*!dtor)) * !radeg


end