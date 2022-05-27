pro ephem2, jd, sol_ra, sol_dec, b0, p, semi_diam, sid_time, dist, $
 xsun, ysun, zsun

;  ephem procedure to calculate solar ephemeris values
;  julian date is input, solar ra, dec, b0, p, etc.
;  time are returned (angles are all in degrees, sid time is gmst in
;  day fraction)

   jul_day = jd - 2451545.d0

   g = 357.528 + 0.9856003*jul_day
   g = g mod 360.
   gl=where(g lt 0.,count)
   if count gt 0 then g(gl) = g(gl) + 360.

   l = 280.466 + 0.9856474*jul_day
   l = l mod 360.
   ll=where(l lt 0.,count)
   if count gt 0 then l(ll) = l(ll) + 360.

   lam = l + 1.915*sin(g*!pi/180.) + 0.020*sin(2.*g*!pi/180.)

   eps = 23.440 - 0.0000004*jul_day

   sin_eps = sin(eps*!pi/180.)
   cos_eps = cos(eps*!pi/180.)
   sin_lam = sin(lam*!pi/180.)
   cos_lam = cos(lam*!pi/180.)

   f = 180./!pi
   t = tan(eps*!pi/360.)^2
   sol_ra = lam - f*t*sin(2.*lam*!pi/180) + (f/2.)*t^2*sin(4.*lam*!pi/180.)
   sol_dec = 180.*asin( sin_eps*sin_lam)/!pi

   sinc = .1265364
   omega = 1.3208652 + 2.436479e-4*jul_day/365.25

   b0 = asin( sin(sinc)*sin(lam*!pi/180.-omega) )
   b0 = b0*180./!pi
   p = atan( -tan(eps*!pi/180.)*cos(lam*!pi/180.) ) $
      + atan( -tan(sinc)*cos(lam*!pi/180.-omega) )
   p = p*180./!pi

;  get sidereal time

   sid_time=togmst(jd)

;  compute earth-sun distance, rectangular coordinates (au),
;  and solar semi-diameter (arcsec)

   dist = 1.00014 - 0.01671*cos(g*!pi/180.) - 0.00014*cos(2.*g*!pi/180.)

   semi_diam = 3600.*0.2666/dist

   xsun = dist*cos_lam
   ysun = dist*cos_eps*sin_lam
   zsun = dist*sin_eps*sin_lam

end
