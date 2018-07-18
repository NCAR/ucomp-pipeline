;+
; Project     : SOHO - CDS
;
; Name        : PB0R
;
; Purpose     : To calculate the solar P, B0 angles and the semi-diameter.
;
; Explanation : Uses semi-rigorous formulae to calculate the solar P (position
;               angle of pole) and B0 (latitude of point at disk centre) angles
;               and also the semi-diameter of the solar disk at the date/time
;               requested.
;
; Use         : IDL> ang = pb0r(date_time,/soho)
;
; Inputs      : date_time  -  the date/time specified in any CDS format
;
; Outputs     : Function returns a 3-element array with
;                                    ang(0)  = P  (degrees)
;                                    ang(1)  = B0 (degrees)
;                                    ang(2)  = R  semi-diameter (arcmin or
;                                                                arcsec if
;                                                                keyword set)
;
; Keywords    : SOHO - if present the semi-diameter returned is as viewed
;                      from the SOHO spacecraft
;               ARCSEC - returns semi-diameter in arcsec rather than arcmins
;               ERROR  - Output keyword containing error message;
;                        a null string is returned if no error occurs
;               RETAIN - passed to get_orbit to determine whether orbit file
;                        is left open or not.
;               EARTH  - set internal environment variable to EARTH
;                        view
;               L0     - L0 value [degrees]
;               STEREO = 'A' or 'B' for STEREO Ahead or Behind
;
; Common      : pb0r_common (internal common block)
;
; Category    : Util, coords
;
; Prev. Hist. : Based on Fortran programs by Hohenkerk and Emerson (RGO)
;
; Written     : CDS/IDL version, C D Pike, RAL, 16-May-94
;
; Modified    : Update semi-diameter calculation, CDP, 20-May-94
;		Version 3, William Thompson, GSFC, 14 November 1994
;			Modified .DAY to .MJD
;               Version 4, CDP, 10-Jan-96
;                  Add SOHO/ARCSEC keywords and make NOW the default.
;               Version 5, Liyun Wang, GSFC/ARC, March 12, 1996
;                  Modified such that point of view can be changed to
;                     SOHO if the env variable SC_VIEW is set to 1
;                     (via the call to USE_SOHO_VIEW)
;                  Added ERROR keyword
;               Version 6, Liyun Wang, GSFC/ARC, March 14, 1996
;                  Replaced call to GET_ORBIT with the IDL call_function
;               Version 7, Liyun Wang, GSFC/ARC, March 21, 1996
;                  Modified such that if no orbit file is found, earth
;                     view is used
;               Version 8, Liyun Wang, GSFC/ARC, April 10, 1996
;                  Set SC_VIEW to 0 if no orbit files are found
;               Version 9, February 6, 1997, Liyun Wang, NASA/GSFC
;                  Changed call to ANYTIM2JD instead of CDS2JD
;               Version 10, April 17 1997, CDP.  Added RETAIN keyword
;               Version 11, July 28 1997, DMZ, fixed bug in common block
;               Version 12, Nov 17 1997, DMZ, added /EARTH
;		Version 13, 26 Jan 1998, William Thompson
;			Correct by 1% if no orbit files are found, instead of
;			setting SC_VIEW to 0.
;			Fix bug involving when to recalculate SOHO positions.
;               Version 14, 7 Jan 1999, Zarro (SMA/GSFC) 
;                       Fixed another bug involving SC_VIEW
;                       (deprecated EARTH keyword)
;               Version 15, 20 Jan 1999, Zarro (SMA/GSFC)
;                       Added check for GET_ORBIT in !path
;		Version 16, 06-Feb-2003, William Thompson, GSFC
;			Fixed bug in common block (Previous fix somehow lost?)
;		Version 17, 20-Feb-2003, Zarro (EER/GSFC) 
;			Added check for IMAGE_TOOL running and removed
;                       silly 'goto'
;               Modified, 8-Jan-2005, Zarro (L-3Com/GSFC) - added
;                       /DEBUG
;               Modified, 23-Oct-2007, Zarro (ADNET) 
;                      - added SOHO B0 angle
;               Modified, 20-Feb-2008, Zarro (ADNET)
;                      - added L0 keyword
;               Modified, 21-Aug-2008, Zarro (ADNET)
;                      - added STEREO by-pass
;               Modified, 21-Feb-2009, Zarro (ADNET)
;                      - added /VERBOSE
;               18-Jun-2010, William Thompson, use WCS_RSUN(), WCS_AU()
;-

FUNCTION  pb0r, date, soho=soho, arcsec=arcsec, error=error,_extra=extra,$
               retain=retain,earth=earth,debug=debug,$
               l0=l0,stereo=stereo,roll_angle=roll_angle,verbose=verbose

  error = '' & l0=0. & roll_angle=0.
  def=[0.,0.,16.]
  if keyword_set(arcsec) then def=[0.,0.,960.]
  if keyword_set(stereo) and keyword_set(soho) then begin
   error='Cannot set /STEREO and /SOHO simultaneously'
   message,error,/cont
   return,def
  endif  

;-- STEREO by-pass

  if keyword_set(stereo) then $
   return,pb0r_stereo(date,arcsec=arcsec,l0=l0,error=error,$
                      stereo=stereo,roll_angle=roll_angle,_extra=extra)

  common pb0r, prev_output, prev_soho, prev_utc,prev_l0, sd_const
  if exist(prev_output) then output = prev_output 
  if exist(prev_l0) then l0=prev_l0
 
;---------------------------------------------------------------------------
;  date supplied?
;---------------------------------------------------------------------------

  warning=''
  utc = anytim2utc(date, /ecs, err=warning)
  if warning ne '' then get_utc, utc, /ecs

;---------------------------------------------------------------------------
; retain option for orbit files?
;---------------------------------------------------------------------------

  if keyword_set(retain) then ret_flag=1 else ret_flag=0

;---------------------------------------------------------------------------
; does it need to recalculate?
;---------------------------------------------------------------------------

  use_soho=keyword_set(soho)

;-- IMAGE_TOOL running, check SC_VIEW environment variable
 
;  if xregistered('image_tool',/noshow) ne 0 then use_soho=soho_view()

  recal = 0
  if n_elements(prev_utc) eq 0 then recal=1 else begin
   if prev_utc ne utc then recal=1 else begin
    if exist(prev_soho) then if prev_soho ne use_soho then recal=1
   endelse
  endelse

  if not exist(output) then recal=1
  if recal then begin

   if keyword_set(debug) then message,'computing with '+anytim2utc(utc,/vms),/cont

;---------------------------------------------------------------------------
;  number of Julian days since 2415020.0
;---------------------------------------------------------------------------

   jd = anytim2jd(utc)
   jd.int = jd.int - 2415020L

;---------------------------------------------------------------------------
;  ignoring difference between UT and ET then ...
;---------------------------------------------------------------------------

   de = DOUBLE(jd.int + jd.frac)

;---------------------------------------------------------------------------
;  get the longitude of the sun etc.
;---------------------------------------------------------------------------
   sun_pos, de, longmed, ra, dec, appl, oblt

;---------------------------------------------------------------------------
;  form aberrated longitude
;---------------------------------------------------------------------------
   lambda = longmed - (20.5D0/3600.0D0)

;---------------------------------------------------------------------------
;  form longitude of ascending node of sun's equator on ecliptic
;---------------------------------------------------------------------------
   node = 73.666666D0 + (50.25D0/3600.0D0)*( (de/365.25d0) + 50.0d0 )
   arg = lambda - node

;---------------------------------------------------------------------------
;  calculate P, the position angle of the pole
;---------------------------------------------------------------------------
   p = (ATAN(-TAN(oblt*!dtor) * COS(appl*!dtor)) + $
        ATAN( -0.12722D0 * COS(arg*!dtor))) * !radeg

;---------------------------------------------------------------------------
;  ... and B0 the tilt of the axis
;---------------------------------------------------------------------------
   b = ASIN( 0.12620D0 * SIN(arg*!dtor) ) * !radeg

;---------------------------------------------------------------------------
;  ... and the semi-diameter
;
;
;  Form the mean anomalies of Venus(MV),Earth(ME),Mars(MM),Jupiter(MJ)
;  and the mean elongation of the Moon from the Sun(D).
;
;---------------------------------------------------------------------------
   t = de/36525.0d0

   mv = 212.6d0   + ( (58517.80D0   * t) MOD 360.0D0 )
   me = 358.476d0 + ( (35999.0498D0 * t) MOD 360.0D0 )
   mm = 319.5d0   + ( (19139.86D0   * t) MOD 360.0D0 )
   mj = 225.3d0   + ( ( 3034.69D0   * t) MOD 360.0D0 )
   d = 350.7d0    + ( (445267.11D0  * t) MOD 360.0D0 )

;---------------------------------------------------------------------------
;  Form the geocentric distance(r) and semi-diameter(sd)
;---------------------------------------------------------------------------
   r = 1.000141d0 - (0.016748d0 - 0.0000418d0*t)*COS(me*!dtor) $
      - 0.000140d0 * COS(2.0d0*me*!dtor)                       $
      + 0.000016d0 * COS((58.3d0 + 2.0D0*mv - 2.0D0*me)*!dtor) $
      + 0.000005d0 * COS((209.1d0 + mv - me)*!dtor)            $
      + 0.000005d0 * COS((253.8d0 - 2.0d0*mm + 2.0d0*me)*!dtor)$
      + 0.000016d0 * COS(( 89.5d0 - mj + me)*!dtor)            $
      + 0.000009d0 * COS((357.1d0 - 2.0d0*mj + 2.0D0*me)*!dtor) $
      + 0.000031D0 * COS(d*!dtor)

;; sd = (0.2665685d0/r)*60.0d0

   if n_elements(sd_const) eq 0 then sd_const = wcs_rsun() / wcs_au()
   sd = asin(sd_const/r)*10800.d0/!dpi

   if use_soho then begin
    warning=''
    have_orbit=have_proc('get_orbit')
    if have_orbit then begin
     dprint, 'Reading the orbit file....'
     pos = call_function('get_orbit',utc, errmsg=warning, retain=ret_flag)
    endif else warning='"get_orbit" function not in !path'

    if warning ne '' then begin
     if keyword_set(verbose) then begin
      message,warning,/cont
      message,'Earth-view used with 1% correction',/cont
     endif
     soho_sd = sd*1.01 & l0=0.d
     output = [p, b, soho_sd]
    endif else begin
     xe = pos.sun_vector_x
     ye = pos.sun_vector_y
     ze = pos.sun_vector_z
     xs = pos.hec_x
     ys = pos.hec_y
     zs = pos.hec_z
     edist = DOUBLE(SQRT(xe*xe+ye*ye+ze*ze))
     sdist = DOUBLE(SQRT(xs*xs+ys*ys+zs*zs))
     if sdist gt 0 then begin
      sd = (sd/60.0d0)*!dtor
      soho_sd = atan(edist*tan(sd)/sdist)*!radeg*60.0d0
     endif else soho_sd=sd
     b=pos.hel_lat_soho*!radeg
     l0=(pos.hel_lon_soho-pos.hel_lon_earth)*!radeg
     output = [p, b, soho_sd]
    endelse
   endif else begin
    output = [p, b, sd] & l0=0.d
   endelse
  endif
 
  prev_soho=use_soho
  prev_utc = utc
  prev_output = output
  prev_l0=l0

  if keyword_set(arcsec) then $
   return, [output[0], output[1], output[2]*60.d0] $
  else return, output

  end



