;+
; Project     :	Multimission
;
; Name        :	GET_SUNSPICE_COORD
;
; Purpose     :	Returns the orbital position of a spacecraft
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	This routine returns the position of a spacecraft in a wide
;               variety of coordinate systems.  It can also be used to return
;               planetary or lunar positions.
;
; Syntax      :	State = GET_SUNSPICE_COORD( DATE, SPACECRAFT )
;
; Examples    :	State = GET_SUNSPICE_COORD( '2006-05-06T11:30:00', 'STEREO-A' )
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
; Opt. Inputs :	None
;
; Outputs     :	The result of the function is the six-value state vector,
;               containing the X,Y,Z coordinates in kilometers, and VX,VY,VZ in
;               km/sec.  If DATE is a vector, then the result will have
;               additional dimensions.
;
; Opt. Outputs:	None
;
; Keywords    : SYSTEM = Character string, giving one of the following
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
;                               SCI     STEREO Science Pointing
;                               HERTN   Heliocentric Ecliptic RTN
;
;                        Case is not important.  RTN and SCI are
;                        spacecraft-centered, and require that the TARGET
;                        keyword be passed, as do HGRTN/HERTN.
;
;               TARGET = Used with SYSTEM="RTN", SYSTEM="HGRTN", SYSTEM="SCI",
;                        or SYSTEM="HERTN" to specify the target, e.g.
;
;                        STATE = GET_SUNSPICE_COORD('2007-01-01, 'A', $
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
;               NOVELOCITY = If set, then only the positions are returned, and
;                            not the velocities.  This is always the case for
;                            GSM and SM coordinates.
;
;               LTIME  = Returned as the light travel time, in seconds.
;
;               METERS = If set, then the coordinates are returned in units of
;                        meters, instead of the default of kilometers.
;                        Velocities are returned as meters/second.  Note
;                        that meters (and meters/second) are required for FITS
;                        header keywords.
;
;               AU     = If set, then the coordinates are returned in
;                        Astronomical Units, instead of the default of
;                        kilometers.  Velocities are returned as AU/sec.
;
;               FOUND  = Byte array containing whether or not the coordinates
;                        were found.  If zero, then the coordinates were
;                        extrapolated.
;
;               ITRF93 = If set, then use the high precision Earth PCK files
;                        loaded by LOAD_SUNSPICE_EARTH instead of the default
;                        IAU_EARTH frame.  Only relevant for GEO, MAG, GSM, and
;                        SM coordinates.
;
;               ERRMSG = If defined and passed, then any error messages will be
;                        returned to the user in this parameter rather than
;                        depending on the MESSAGE routine in IDL.  If no errors
;                        are encountered, then a null string is returned.  In
;                        order to use this feature, ERRMSG must be defined
;                        first, e.g.
;
;                               ERRMSG = ''
;                               State = GET_SUNSPICE_COORD( ERRMSG=ERRMSG, ... )
;                               IF ERRMSG NE '' THEN ...
;
;               Will also accept any LOAD_SUNSPICE or ANYTIM2UTC keywords.
;
; Calls       :	ANYTIM2UTC, CONCAT_DIR, CSPICE_STR2ET, CSPICE_SPKEZR,
;               LOAD_SUNSPICE, CONVERT_SUNSPICE_GEO2MAG,
;               CONVERT_SUNSPICE_GSE2GSM, CONVERT_SUNSPICE_GSE2SM,
;               CSPICE_CONICS, PARSE_SUNSPICE_NAME, GET_SUNSPICE_CONIC,
;               CONVERT_SUNSPICE_COORD
;
; Common      :	None
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
; Prev. Hist. :	Based on GET_STEREO_COORD
;
; History     :	Version 1, 25-Apr-2016, William Thompson, GSFC
;               Version 2, 29-Jun-2016, WTT, added ITRF93 keyword, SOHOHERTN
;               Version 3, 06-Feb-2017, WTT, support Solar Orbiter (-144)
;               Version 4, 24-Mar-2017, WTT, support Solar Probe Plus (-96)
;
; Contact     :	WTHOMPSON
;-
;
function get_sunspice_coord, date, spacecraft, system=k_system, ltime=ltime, $
                           corr=k_corr, precess=precess, target=target, $
                           novelocity=novelocity, meters=meters, au=au, $
                           found=found, errmsg=errmsg, itrf93=itrf93, _extra=_extra
;
on_error, 2
;
if n_params() ne 2 then begin
    message = 'Syntax:  State = GET_SUNSPICE_COORD( DATE, SPACECRAFT )'
    goto, handle_error
endif
;
;  Determine which spacecraft (or planetary body) was requested, and translate
;  it into the proper input for SPICE.
;
sc = parse_sunspice_name(spacecraft)
;
;  Convert the date/time to UTC.
;
message = ''
utc = anytim2utc(date, /ccsds, errmsg=message, _extra=_extra)
if message ne '' then goto, handle_error
;
;  Parse the keywords.
;
if n_elements(k_corr) eq 1 then corr = k_corr else corr = 'None'
;
;  Make sure that the ephemeris files are loaded.
;
message = ''
load_sunspice, sc, errmsg=message, _extra=_extra
if message ne '' then goto, handle_error
;
;  Convert the date/time to ephemeris time.
;
cspice_str2et, utc, et
;
;  Determine which coordinate system was specified.
;
if n_elements(k_system) eq 1 then system=strupcase(k_system) else system='HCI'
if system eq 'HEQ' then system = 'HEEQ'
if system eq strmid('CARRINGTON',0,strlen(system)) then system = 'CARRINGTON'
;
;  Radial-tangential-normal coordinate systems require mission-specific frame
;  definition files to be loaded.
;
if (system eq 'HGRTN') or (system eq 'RTN') then begin
    if sc eq '-234' then begin
        frame = 'STAHGRTN'
    end else if sc eq '-235' then begin
        frame = 'STBHGRTN'
    end else if sc eq '-21' then begin
        frame = 'SOHOHGRTN'
    end else if sc eq '-144' then begin
        frame = 'SOLOHGRTN'
    end else if sc eq '-96' then begin
        frame = 'SPPHGRTN'
    end else begin
        if not !quiet then print, 'Assuming Earth observation'
        frame = 'GEORTN'
    endelse
    if n_elements(target) eq 0 then begin
        message = 'TARGET not specified'
        goto, handle_error
    endif
endif
;
;  The STEREO Science Pointing frame requires a mission-specific frame
;  definition file to be loaded.
;
if (system eq 'SCI') then begin
    if sc eq '-234' then begin
        frame = 'STASCPNT'
    end else if sc eq '-235' then begin
        frame = 'STBSCPNT'
    end else begin
        message = 'Unable to recognize spacecraft specification'
        goto, handle_error
    endelse
    if n_elements(target) eq 0 then begin
        message = 'TARGET not specified'
        goto, handle_error
    endif
endif
;
;  The Helioecliptic Radial-Tangential-Normal frame requires a mission-specific
;  frame definition file to be loaded.
;
if (system eq 'HERTN') then begin
    if sc eq '-234' then begin
        frame = 'STAHERTN'
    end else if sc eq '-235' then begin
        frame = 'STBHERTN'
    end else if sc eq '-21' then begin
        frame = 'SOHOHERTN'
    end else if sc eq '-144' then begin
        frame = 'SOLOHERTN'
    end else if sc eq '-96' then begin
        frame = 'SPPHERTN'
    end else begin
        message = 'Unable to recognize spacecraft specification'
        goto, handle_error
    endelse
    if n_elements(target) eq 0 then begin
        message = 'TARGET not specified'
        goto, handle_error
    endif
endif
;
;  If conic parameters are available, then separate the times into those before
;  and after the last ephemeris date.
;
n0 = 0
n1 = n_elements(et)
get_sunspice_conic, sc, maxdate, elts
if n_elements(maxdate) eq 1 then begin
    w1 = where(utc le maxdate, n1, complement=w0, ncomplement=n0)
    if n0 gt 0 then begin
        cspice_str2et, maxdate, et0
        et[w0] = et0
    endif
endif
;
;  Determine whether or not the ITRF93 kernels for Earth should be loaded.
;
if keyword_set(itrf93) then begin
    message = ''
    load_sunspice_earth, errmsg=message, _extra=_extra
    if message ne '' then goto, handle_error
    earth_frame = 'ITRF93'
end else earth_frame = 'IAU_EARTH'
;
;  Based on the coordinate system requested, get the state and light travel
;  time.
;
catch, error_status
if error_status ne 0 then begin
    message = !error_state.msg
    catch, /cancel
    goto, handle_error
endif
case strupcase(system) of
    'GEI': cspice_spkezr, sc, et, 'J2000', corr, 'Earth', state, ltime
    'GEO': cspice_spkezr, sc, et, earth_frame, corr, 'Earth', state, ltime
    'MAG': begin
        cspice_spkezr, sc, et, earth_frame, corr, 'Earth', state, ltime
        convert_sunspice_geo2mag, utc, state
        end
    'GSE': cspice_spkezr, sc, et, 'GSE', corr, 'Earth', state, ltime
    'GSM': begin
        cspice_spkezr, sc, et, 'GSE', corr, 'Earth', state, ltime
        convert_sunspice_gse2gsm, utc, state, itrf93=itrf93
        end
    'SM': begin
        cspice_spkezr, sc, et, 'GSE', corr, 'Earth', state, ltime
        convert_sunspice_gse2sm, utc, state, itrf93=itrf93
        end
    'GAE': begin
        if keyword_set(precess) then frame='ECLIPDATE' else frame='ECLIPJ2000'
        cspice_spkezr, sc, et, frame, corr, 'Earth', state, ltime
        end
    'HCI': cspice_spkezr, sc, et, 'HCI', corr, 'Sun', state, ltime
    'HAE': begin
        if keyword_set(precess) then frame='ECLIPDATE' else frame='ECLIPJ2000'
        cspice_spkezr, sc, et, frame, corr, 'Sun', state, ltime
        end
    'HEE': cspice_spkezr, sc, et, 'HEE', corr, 'Sun', state, ltime
    'HEEQ': cspice_spkezr, sc, et, 'HEEQ', corr, 'Sun', state, ltime
    'CARRINGTON': cspice_spkezr, sc, et, 'IAU_SUN', corr, 'Sun', state, ltime
    'HGRTN': cspice_spkezr, target, et, frame, corr, 'Sun', state, ltime
    'RTN': cspice_spkezr, target, et, frame, corr, sc, state, ltime
    'SCI': cspice_spkezr, target, et, frame, corr, sc, state, ltime
    'HERTN': cspice_spkezr, target, et, frame, corr, 'Sun', state, ltime
    else: begin
        message = 'Unrecognized coordinate system'
        goto, handle_error
    endelse
endcase
catch, /cancel
;
;  If there are times beyond the end of the valid range, use cspice_conic to
;  fill in the times.
;
sz = size(et)
if sz[0] eq 0 then found = 1b else found = replicate(1b, sz[1:sz[0]])
if n0 gt 0 then begin
    found[w0] = 0b
    for i=0L,n0-1 do begin
        utc0 = utc[w0[i]]
        cspice_str2et, utc0, et
        cspice_conics, elts, et, temp
        state[*,w0[i]] = temp
        ltime[w0[i]] = -1
    endfor
    temp = state[*,w0]
    convert_sunspice_coord, utc[w0], temp, 'HAE', system, itrf93=itrf93, _extra=_extra
    state[*,w0] = temp
endif
;
;  If requested, strip off the velocity vector.
;
if keyword_set(novelocity) then state = state[0:2,*,*,*,*,*,*,*]
;
;  Define the proper units, and return.
;
if keyword_set(meters) then state = state*1000 else $
  if keyword_set(au) then state = state / 1.4959787D8
;
return, state
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message else $
  errmsg = 'GET_SUNSPICE_COORD: ' + message
;
end
