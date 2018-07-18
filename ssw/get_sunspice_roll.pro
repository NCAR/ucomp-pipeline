;+
; Project     :	Multimission
;
; Name        :	GET_SUNSPICE_ROLL
;
; Purpose     :	Returns the roll angle of a spacecraft
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	This routine returns the roll angle of a spacecraft, in a
;               variety of coordinate systems.
;
;               A positive roll is defined as a right-handed rotation about the
;               spacecraft +X axis.  This sign convention is opposite from
;               that used by GET_SUNSPICE_HPC_POINT, which uses the FITS sign
;               convention.
;
; Syntax      :	Roll = GET_SUNSPICE_ROLL( DATE, SPACECRAFT  [, YAW, PITCH ] )
;
; Examples    :	Roll = GET_SUNSPICE_ROLL( '2006-05-06T11:30:00', 'STEREO-A' )
;
;               Use the following to get the pointing in R.A. & Dec.
;
;               Roll = GET_SUNSPICE_ROLL(Date, SC, RA, Dec, SYSTEM='GEI')
;
;               Or this for ecliptic coordinates.
;
;               Roll = GET_SUNSPICE_ROLL(Date, SC, Lon, Lat, SYSTEM='HAE')
;
; Inputs      :	DATE       = The date and time.  This can be input in any
;                            format accepted by ANYTIM2UTC, and can also be an
;                            array of values.
;
;               SPACECRAFT = The name or NAIF numeric code of a spacecraft.
;                            See PARSE_SUNSPICE_NAME for more information about
;                            recognized names.  Case is not important.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the roll angle in degrees.
;
; Opt. Outputs:	YAW, PITCH = The pointing in degrees.
;
; Keywords    : SYSTEM = Character string, giving one of the following
;                        standard coordinate systems:
;
;                               GEI     Geocentric Equatorial Inertial
;                               GEO     Geographic
;                               GSE     Geocentric Solar Ecliptic
;                               MAG     Geomagnetic
;                               GSM     Geocentric Solar Magnetospheric
;                               SM      Solar Magnetic
;                               HCI     Heliocentric Inertial
;                               HAE     Heliocentric Aries Ecliptic
;                               HEE     Heliocentric Earth Ecliptic
;                               HEEQ    Heliocentric Earth Equatorial (or HEQ)
;                               Carrington (can be abbreviated)
;                               HGRTN   Heliocentric Radial-Tangential-Normal
;                               RTN     Radial-Tangential-Normal (default)
;                               HERTN   Heliocentric Ecliptic RTN
;                               STPLN   STEREO Mission Plane
;
;                        This procedure does not work with SYSTEM='HPC'.  Use
;                        SYSTEM='RTN' instead.
;
;               INSTRUMENT = The name of an instrument or sub-instrument with a
;                            defined reference frame.  This capability is not
;                            yet implemented--this keyword is included as a
;                            placeholder for when it is.
;
;                            The default is to return the C-matrix for the
;                            spacecraft as a whole, rather than for any
;                            specific instrument.
;
;               TOLERANCE = The tolerance to be used when looking for pointing
;                           information, in seconds.  The default is 1000.
;
;               FOUND  = Byte array containing whether or not the pointings
;                        were found.
;
;               RADIANS= If set, then the units for all three parameters will
;                        be radians.  The default is degrees.
;
;               POST_CONJUNCTION= A STEREO-specific keyword.  If set, then
;                                 modify the roll angle by 180 degrees if the
;                                 date is after 2015-05-19.  Earlier dates are
;                                 unaffected, as are the yaw and pitch values.
;
;               ERRMSG = If defined and passed, then any error messages will be
;                        returned to the user in this parameter rather than
;                        depending on the MESSAGE routine in IDL.  If no errors
;                        are encountered, then a null string is returned.  In
;                        order to use this feature, ERRMSG must be defined
;                        first, e.g.
;
;                               ERRMSG = ''
;                               Pnt = GET_SUNSPICE_ROLL( ERRMSG=ERRMSG, ... )
;                               IF ERRMSG NE '' THEN ...
;
;               Will also accept any LOAD_SUNSPICE or ANYTIM2UTC keywords.
;
; Calls       :	DATATYPE, GET_SUNSPICE_CMAT, CSPICE_M2EUL, PARSE_SUNSPICE_NAME
;
; Common      :	None.
;
; Restrictions:	At least one CK file must be loaded.
;
;               This procedure works in conjunction with the Icy/CSPICE
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
; Prev. Hist. :	Based on GET_STEREO_HPC_POINT
;
; History     :	Version 1, 12-Jul-2006, William Thompson, GSFC
;               Version 2, 20-Jul-2006, William Thompson, GSFC
;                       Added optional parameters YAW, PITCH
;               Version 3, 01-Sep-2006, William Thompson, GSFC
;                       Call PARSE_SUNSPICE_NAME, fix bug when SYSTEM not passed
;               Version 4, 29-Nov-2006, William Thompson, GSFC
;                       Fix bug of wrong sign of pitch (or yaw for SCI)
;               Version 5, 17-Jun-2015, William Thompson, GSFC
;                       Added keyword POST_CONJUNCTION
;               Version 6, 29-Apr-2016, WTT, renamed from GET_STEREO_ROLL
;
; Contact     :	WTHOMPSON
;-
;
function get_sunspice_roll, date, spacecraft, yaw, pitch, system=k_system, $
                          found=found, instrument=instrument, $
                          degrees=degrees, radians=radians, $
                          post_conjunction=post_conjunction, $
                          tolerance=tolerance, errmsg=errmsg, _extra=_extra
;
on_error, 2
if n_params() lt 2 then begin
    message = 'Syntax:  Pointing = GET_SUNSPICE_ROLL( DATE, SPACECRAFT )'
    goto, handle_error
endif
;
;  Define the units.
;
units = 180.d0 / !dpi
if keyword_set(radians) then units = 1
;
;  Determine which spacecraft was requested, and translate it into the proper
;  input for SPICE.
;
inst = 0L
sc_ahead  = '-234'
sc_behind = '-235'
sc = parse_sunspice_name(spacecraft)
;
;  Start by deriving the C-matrices.  Make sure that DATE is treated as a
;  vector.
;
message = ''
if n_elements(k_system) eq 1 then system=strupcase(k_system) else system='RTN'
cmat = get_sunspice_cmat(date[*], spacecraft, system=system, found=found, $
                       instrument=instrument, tolerance=tolerance, $
                       errmsg=message, _extra=_extra)
if message ne '' then goto, handle_error
;
n = n_elements(date)
if n eq 1 then roll = 0.d0 else roll = dblarr(n)
pitch = roll
yaw   = roll
;
twopi  = !dpi * 2.d0
halfpi = !dpi / 2.d0
sci_frame = strupcase(system) eq 'SCI'
for i=0L,n-1L do begin
    if not sci_frame then begin
        cspice_m2eul, cmat[*,*,i], 1, 2, 3, rroll, ppitch, yyaw
        ppitch = -ppitch
        rroll = rroll - halfpi
        if sc eq sc_behind then rroll = rroll + !dpi
        if abs(rroll) gt !dpi then rroll = rroll - sign(twopi, rroll)
    end else begin
        cspice_m2eul, cmat[*,*,i], 1, 3, 2, rroll, ppitch, yyaw
        yyaw = -yyaw
    endelse
;
;  If the POST_CONJUNCTION keyword was set, then modify the roll angle by 180
;  degrees.
;
    if keyword_set(post_conjunction) and $
      ((sc eq sc_ahead) or (sc eq sc_behind)) then begin
        if anytim2utc(date[i],/ccsds) ge '2015-05-19' then begin
            rroll = rroll + !dpi
            if rroll gt !dpi then rroll = rroll - twopi
        endif
    endif
;
    roll[i]  = units * rroll
    pitch[i] = units * ppitch
    yaw[i]   = units * yyaw
endfor
;
;  Reformat the output arrays to match the input date/time array.
;
if n gt 1 then begin
    sz = size(date)
    dim = [sz[1:sz[0]]]
    roll  = reform(roll,  dim, /overwrite)
    pitch = reform(pitch, dim, /overwrite)
    yaw   = reform(yaw,   dim, /overwrite)
endif
;
return, roll
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message else $
  errmsg = 'GET_SUNSPICE_ROLL: ' + message
;
end
