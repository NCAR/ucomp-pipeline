;+
; Project     :	Multimission
;
; Name        :	GET_SUNSPICE_LONLAT
;
; Purpose     :	Returns the angular orbital position of a spacecraft
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	This routine returns the angular position of a spacecraft in a
;               wide variety of coordinate systems.  It can also be used to
;               return planetary or lunar positions.
;
; Syntax      :	State = GET_SUNSPICE_LONLAT( DATE, SPACECRAFT )
;
; Examples    :	State = GET_SUNSPICE_LONLAT( '2006-05-06T11:30:00', 'STEREO-A' )
;
; Inputs      :	DATE       = The date and time.  This can be input in any
;                            format accepted by ANYTIM2UTC, and can also be an
;                            array of values.
;
;               SPACECRAFT = The name or NAIF numeric code of a spacecraft.
;                            See PARSE_SUNSPICE_NAME for more information about
;                            recognized names.  Can also be the name of a solar
;                            system body, e.g. "Earth", "Mars", "Moon", etc.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is a three-value state vector,
;               containing the radius in kilometers, and the longitude and
;               latitude in radians.  If DATE is a vector, then the result will
;               have additional dimensions.
;
; Opt. Outputs:	None.
;
; Keywords    : PLANETOGRAPHIC = If set, then planetographic coordinates are
;                                returned instead of planetocentric
;                                coordinates.  The distinction depends on the
;                                oblateness of the planetary body, and whether
;                                it rotates in the prograde or retrograde
;                                sense.  Also, the first element in the result
;                                array will be altitude above the surface,
;                                instead of radial distance.  Only used with
;                                GEI or GEO coordinates.
;
;               DEGREES = If set, then the longitude and latitude are returned
;                         in units of degrees, rather than radians.
;
;               The remaining keywords are passed to GET_SUNSPICE_COORD:
;
;               SYSTEM = Character string, giving one of the following
;                        standard coordinate systems:
;
;                               GEI     Geocentric Equatorial Inertial
;                               GEO     Geographic
;                               GSE     Geocentric Solar Ecliptic
;                               GAE     Geocentric Aries Ecliptic
;                               MAG     Geomagnetic
;                               GSM     Geocentric Solar Magnetospheric
;                               SM      Solar Magnetic
;                               HCI     Heliocentric Inertial (default)
;                               HAE     Heliocentric Aries Ecliptic
;                               HEE     Heliocentric Earth Ecliptic
;                               HEEQ    Heliocentric Earth Equatorial (or HEQ)
;                               Carrington (can be abbreviated)
;                               HGRTN   Heliocentric Radial-Tangential-Normal
;                               RTN     Radial-Tangential-Normal
;                               HPC     Helioprojective-Cartesian
;                               SCI     STEREO Science Pointing
;                               HERTN   Heliocentric Ecliptic RTN
;
;                        Case is not important.  RTN, HPC, and SCI are
;                        spacecraft-centered, and require that the TARGET
;                        keyword be passed, as do HGRTN/HERTN.
;
;               TARGET = Used with SYSTEM="RTN", ="HGRTN", ="HPC", ="SCI",
;                        or SYSTEM="HERTN" to specify the target, e.g.
;
;                        STATE = GET_SUNSPICE_LONLAT('2007-01-01, 'A', $
;                                       SYSTEM='RTN',Target='Earth')
;
;               CORR = Aberration correction.  Default is 'None'.  Other
;                      possible values are:
;
;                       'LT'    Light travel time
;                       'LT+S'  Light travel time plus stellar aberration
;                       'XLT'   Light travel time, transmission case
;                       'XLT+S' Light travel plus aberration, transmission case
;
;               PRECESS = If set, then ecliptic coordinates are precessed from
;                         the J2000 reference frame to the mean ecliptic of
;                         date.  Only used for HAE/GAE.  Default is PRECESS=0.
;                         GSE and HEE use the ecliptic of date by definition.
;
;               LTIME  = Returned as the light travel time, in seconds.
;
;               METERS = If set, then the radius is returned in units of
;                        meters, instead of the default of kilometers.  Note
;                        that meters are required for FITS header keywords.
;
;               AU     = If set, then the radius is returned in Astronomical
;                        Units, instead of the default of kilometers.
;
;               POS_LONG = If set, then force the output longitude to be
;                         positive, i.e. between 0 and 360 degrees.  The
;                         default is to return values between +/- 180 degrees,
;                         except for CARRINGTON, which is 0-360 by default.
;
;               FOUND  = Byte array containing whether or not the coordinates
;                        were found.  If zero, then the coordinates were
;                        extrapolated.
;
;               ERRMSG = If defined and passed, then any error messages will be
;                        returned to the user in this parameter rather than
;                        depending on the MESSAGE routine in IDL.  If no errors
;                        are encountered, then a null string is returned.  In
;                        order to use this feature, ERRMSG must be defined
;                        first, e.g.
;
;                               ERRMSG = ''
;                               State = GET_SUNSPICE_LONLAT( ERRMSG=ERRMSG, ... )
;                               IF ERRMSG NE '' THEN ...
;
;               Will also accept any LOAD_SUNSPICE or ANYTIM2UTC keywords.
;
; Calls       :	GET_SUNSPICE_COORD, CSPICE_RECLAT
;
; Common      :	None.
;
; Restrictions:	This procedure works in conjunction with the Icy/CSPICE
;               package, which is implemented as an IDL Dynamically Loadable
;               Module (DLM).  The Icy source code can be downloaded from
;
;                       ftp://naif.jpl.nasa.gov/pub/naif/toolkit/IDL
;
;               Because this uses dynamic frames, it requires Icy/CSPICE
;               version N0058 or higher.
;
; Side effects:	Will automatically load the SPICE ephemeris files, if not
;               already loaded.
;
; Prev. Hist. :	Based on STEREO_COORD_DEMO
;
; History     :	Version 1, 29-Aug-2005, William Thompson, GSFC
;               Version 2, 30-Aug-2005, William Thompson, GSFC
;                       Added units keywords DEGREES, METERS and AU.
;               Version 3, 21-Sep-2005, William Thompson, GSFC
;                       Limit /PLANETOGRAPHIC to GEO or GEI coordinates
;               Version 4, 03-Oct-2006, William Thompson, GSFC
;                       Add support for HPC coordinates
;               Version 5, 13-Mar-2006, William Thompson, GSFC
;                       Added FOUND keyword
;               Version 6, 23-Feb-2009, William Thompson, GSFC
;                       Make Carrington longitude between 0-360 degrees
;               Version 7, 14-Aug-2009, WTT, Added keyword POS_LONG
;               Version 8, 27-Apr-2016, WTT, renamed from GET_STEREO_LONLAT
;
; Contact     :	WTHOMPSON
;-
;
function get_sunspice_lonlat, date, spacecraft, system=k_system, ltime=ltime, $
                            corr=corr, precess=precess, target=target, $
                            planetographic=planetographic, errmsg=errmsg, $
                            meters=meters, au=au, degrees=degrees, $
                            pos_long=pos_long, found=found, _extra=_extra
;
on_error, 2
if n_params() ne 2 then begin
    message = 'Syntax:  State = GET_SUNSPICE_LONLAT( DATE, SPACECRAFT )'
    goto, handle_error
endif
;
;  Determine which coordinate system was specified.
;
if n_elements(k_system) eq 1 then system=strupcase(k_system) else system='HCI'
if system eq 'HEQ' then system = 'HEEQ'
if system eq strmid('CARRINGTON',0,strlen(system)) then system = 'CARRINGTON'
;
;  If HPC was selected, calculate using RTN and apply a correction.
;
if system eq 'HPC' then begin
    system = 'RTN'
    hpc_conv = 1
end else hpc_conv = 0
;
;  Call GET_SUNSPICE_COORD to get the rectangular coordinates.
;
message = ''
state = get_sunspice_coord(date, spacecraft, system=system, ltime=ltime, $
                         corr=corr, precess=precess, target=target, $
                         meters=meters, au=au, /novelocity, errmsg=message, $
                         found=found, _extra=_extra)
if message ne '' then goto, handle_error
;
;  If /PLANETOGRAPHIC was passed, then get the body oblateness, and call
;  CSPICE_RECGEO to calculate the longitude, latitude, and altitude.
;
if keyword_set(planetographic) and ((system eq 'GEO') or (system eq 'GEI')) $
  then begin
    cspice_bodvar, 399, 'RADII' , radii
    if keyword_set(meters) then radii = radii*1000 else $
      if keyword_set(au) then radii = radii / 1.4959787D8
    flat = (radii[0]-radii[2]) / radii[0]
    cspice_recgeo, state, radii[0], flat, longitude, latitude, altitude
    if keyword_set(degrees) then begin
        longitude = (180.d0 / !dpi) * longitude 
        latitude  = (180.d0 / !dpi) * latitude
    endif
    state[0,*] = altitude
    state[1,*] = longitude
    state[2,*] = latitude
;
;  Otherwise, use CSPICE_RECLAT to convert the rectangular coordinates into
;  radius, longitude, and latitude.
;
end else begin
    cspice_reclat, state, radius, longitude, latitude
;
;  If HPC, then apply a correction to the RTN coordinates.
;
    if hpc_conv then begin
        twopi = 2.d0 * !dpi
        longitude = !dpi - longitude
        w = where(longitude gt !dpi, count)
        if count gt 0 then longitude[w] = longitude[w] - twopi
        w = where(longitude lt -!dpi, count)
        if count gt 0 then longitude[w] = longitude[w] + twopi
    endif
;
;  If CARRINGTON, or the POS_LONG keyword is set, then make sure the longitude
;  is between 0 and 360.
;
    if (system eq 'CARRINGTON') or keyword_set(pos_long) then begin
        twopi = 2.d0 * !dpi
        w = where(longitude lt 0, count)
        if count gt 0 then longitude[w] = longitude[w] + twopi
    endif
;
;  Convert to degrees, if necessary.
;
    if keyword_set(degrees) then begin
        longitude = (180.d0 / !dpi) * longitude 
        latitude  = (180.d0 / !dpi) * latitude
    endif
;
;  Store in the STATE array.
;
    state[0,*] = radius
    state[1,*] = longitude
    state[2,*] = latitude
endelse
;
return, state
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message else $
  errmsg = 'GET_SUNSPICE_LONLAT: ' + message
;
end
