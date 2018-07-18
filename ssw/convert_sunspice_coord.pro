;+
; Project     :	Multimission
;
; Name        :	CONVERT_SUNSPICE_COORD
;
; Purpose     :	Converts between coordinate systems
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	This routine converts coordinate arrays, such as those returned
;               by GET_SUNSPICE_COORD, from one coordinate system to another.
;
; Syntax      :	CONVERT_SUNSPICE_COORD, DATE, COORD, FROM, TO
;
; Examples    :	CONVERT_SUNSPICE_COORD, '2006-05-06T11:30', COORD, 'HCI', 'GSE'
;
; Inputs      :	DATE    = The date and time.  This can be input in any format
;                         accepted by ANYTIM2UTC, and can also be an array of
;                         values.
;
;               COORD   = Either the six-value state vector, containing the
;                         X,Y,Z coordinates, and VX,VY,VZ velocities, or the
;                         just the three-value coordinates.  Can also be a 6xN
;                         or 3xN array.  If DATE is a vector, then N must be
;                         the size of DATE.
;
;               FROM    = Character string, giving one of the following
;                         standard coordinate systems to convert from:
;
;                               GEI     Geocentric Equatorial Inertial
;                               GEO     Geographic
;                               GSE     Geocentric Solar Ecliptic
;                               GAE     Geocentric Aries Ecliptic
;                               MAG     Geomagnetic
;                               GSM     Geocentric Solar Magnetospheric
;                               SM      Solar Magnetic
;                               HCI     Heliocentric Inertial
;                               HAE     Heliocentric Aries Ecliptic
;                               HEE     Heliocentric Earth Ecliptic
;                               HEEQ    Heliocentric Earth Equatorial (or HEQ)
;                               Carrington (can be abbreviated)
;                               GRTN    Geocentric Radial-Tangential-Normal
;                               HGRTN   Heliocentric Radial-Tangential-Normal
;                               RTN     Radial-Tangential-Normal
;                               SCI     STEREO Science Pointing
;                               HERTN   Heliocentric Ecliptic RTN
;                               STPLN   Stereo Mission Plane
;
;                         Case is not important.  The last five require that
;                         the SPACECRAFT keyword be passed.  Any unrecognized
;                         spacecraft identification will be assumed to be
;                         Earth-based.
;
;               TO      = Character string, as above, giving the coordinate
;                         system to convert to.
;
; Opt. Inputs :	None.
;
; Outputs     :	COORD   = Returned as the converted coordinates.
;
; Opt. Outputs:	None.
;
; Keywords    : PRECESS = If set, then ecliptic coordinates are precessed from
;                         the J2000 reference frame to the mean ecliptic of
;                         date.  Only used for HAE/GAE.  Default is PRECESS=0.
;                         GSE and HEE use the ecliptic of date by definition.
;
;               SPACECRAFT = Used when either the FROM or TO system is HGRTN,
;                            RTN, or SCI.  See PARSE_SUNSPICE_NAME for more
;                            information about recognized names.
;
;               IGNORE_ORIGIN = If set, the origins of the FROM and TO
;                         coordinate systems are ignored.  This is used for
;                         vectors which only indicate pointing, such as the
;                         direction of a star.
;
;               METERS = If set, then the coordinates are in units of meters,
;                        instead of the default of kilometers.  Velocities are
;                        in meters/second.  This keyword is important if the
;                        coordinate conversion involves an origin shift.
;
;               AU     = If set, then the coordinates are in Astronomical
;                        Units, instead of the default of kilometers.
;                        Velocities are in AU/sec.
;
;               ITRF93 = If set, then use the high precision Earth PCK files
;                        loaded by LOAD_SUNSPICE_EARTH instead of the default
;                        IAU_EARTH frame.  Only relevant for GEO, MAG, GSM, and
;                        SM coordinates.
;
;               ERRMSG  = If defined and passed, then any error messages will
;                         be returned to the user in this parameter rather than
;                         depending on the MESSAGE routine in IDL.  If no
;                         errors are encountered, then a null string is
;                         returned.  In order to use this feature, ERRMSG must
;                         be defined first, e.g.
;
;                               ERRMSG = ''
;                               CONVERT_SUNSPICE_COORD, ERRMSG=ERRMSG, ...
;                               IF ERRMSG NE '' THEN ...
;
;               Will also accept any LOAD_SUNSPICE or ANYTIM2UTC keywords.
;
; Calls       :	ANYTIM2UTC, CSPICE_STR2ET, CSPICE_SPKEZR, CSPICE_PXFORM,
;               CSPICE_SXFORM, LOAD_SUNSPICE, CONVERT_SUNSPICE_GEO2MAG,
;               CONVERT_SUNSPICE_GSE2GSM, CONVERT_SUNSPICE_GSE2SM, PARSE_SUNSPICE_NAME
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
; Prev. Hist. :	Based on CONVERT_STEREO_COORD
;
; History     :	Version 1, 27-Apr-2016, William Thompson, GSFC
;               Version 2, 29-Jun-2016, WTT, added ITRF93 keyword, SOHOHERTN
;               Version 3, 06-Feb-2017, WTT, support Solar Orbiter (-144)
;               Version 4, 24-Mar-2017, WTT, support Solar Probe Plus (-96)
;
; Contact     :	WTHOMPSON
;-
;
pro convert_sunspice_coord, date, coord, system_from, system_to, $
                            spacecraft=spacecraft, precess=precess, $
                            errmsg=errmsg, ignore_origin=ignore_origin, $
                            meters=meters, au=au, itrf93=itrf93, _extra=_extra
;
;  Check the input parameters.
;
on_error, 2
if n_params() ne 4 then begin
    message = 'Syntax:  CONVERT_SUNSPICE_COORD, DATE, COORD, FROM, TO'
    goto, handle_error
endif
;
n_date = n_elements(date)
if n_date eq 0 then begin
    message = 'DATE not defined'
    goto, handle_error
endif
;
sz = size(coord)
if sz[0] eq 0 then begin
    message = 'COORD must be an array'
    goto, handle_error
endif
;
n_vec = sz[1]
if (n_vec ne 3) and (n_vec ne 6) then begin
    message = 'First dimension of COORD must be either 3 or 6'
    goto, handle_error
endif
;
if sz[0] gt 1 then n_coord = product(sz[2:sz[0]]) else n_coord = 1
if (n_date gt 1) and (n_date ne n_coord) then begin
    message = 'Incompatible DATE and COORD arrays'
    goto, handle_error
endif
;
;  If necessary, reform the coordinate array to be two-dimensional.
;
if sz[0] gt 2 then coord = reform(coord, n_vec, n_coord, /overwrite)
;
;  Determine which spacecraft was requested, and translate it into the proper
;  input for SPICE.
;
if n_elements(spacecraft) eq 0 then sc = 'None' else $
  sc = parse_sunspice_name(spacecraft)
;
;  Convert the date/time to UTC.
;
message = ''
utc = anytim2utc(date, /ccsds, errmsg=message, _extra=_extra)
if message ne '' then goto, handle_error
;
;  Make sure that the ephemeris files are loaded.
;
message = ''
if sc ne 'None' then load_sunspice, sc, errmsg=message, _extra=_extra else $
  load_sunspice_gen, errmsg=message
if message ne '' then goto, handle_error
;
;  Convert the date/time to ephemeris time.
;
cspice_str2et, utc, et
;
;  Determine which coordinate systems were specified.
;
from = strupcase(system_from)
if from eq 'HEQ' then from = 'HEEQ'
if from eq strmid('CARRINGTON',0,strlen(from)) then from = 'CARRINGTON'
;
to = strupcase(system_to)
if to eq 'HEQ' then to = 'HEEQ'
if to eq strmid('CARRINGTON',0,strlen(to)) then to = 'CARRINGTON'
;
;  Determine the base systems.  If necessary, convert to BASE_FROM.
;
base_from = from
if from eq 'MAG' then begin
    message = ''
    convert_sunspice_geo2mag, utc, coord, /inverse, errmsg=message
    if message ne '' then goto, handle_error
    base_from = 'GEO'
endif
if from eq 'GSM' then begin
    message = ''
    convert_sunspice_gse2gsm, utc, coord, /inverse, itrf93=itrf93, errmsg=message
    if message ne '' then goto, handle_error
    base_from = 'GSE'
endif
if from eq 'SM' then begin
    message = ''
    convert_sunspice_gse2sm,  utc, coord, /inverse, itrf93=itrf93, errmsg=message
    if message ne '' then goto, handle_error
    base_from = 'GSE'
endif
;
;  For HGRTN, RTN, or SCI coordinates, define frame_from based on the
;  spacecraft.
;
if (from eq 'HGRTN') or (from eq 'RTN') then case sc of
    '-234': frame_from = 'STAHGRTN'
    '-235': frame_from = 'STBHGRTN'
    '-21':  frame_from = 'SOHOHGRTN'
    '-144': frame_from = 'SOLOHGRTN'
    '-96':  frame_from = 'SPPHGRTN'
    else: begin
        if not !quiet then print, 'Assuming Earth observation'
        frame_from = 'GEORTN'
    end
endcase
;
if (from eq 'SCI') then case sc of
    '-234': frame_from = 'STASCPNT'
    '-235': frame_from = 'STBSCPNT'
    else: begin
        message = 'Unable to recognize spacecraft specification'
        goto, handle_error
    end
endcase
;
if (from eq 'HERTN') then case sc of
    '-234': frame_from = 'STAHERTN'
    '-235': frame_from = 'STBHERTN'
    '-21':  frame_from = 'SOHOHERTN'
    '-144': frame_from = 'SOLOHERTN'
    '-96':  frame_from = 'SPPHERTN'
    else: begin
        message = 'Unable to recognize spacecraft specification'
        goto, handle_error
    end
endcase
;
if (from eq 'STPLN') then case sc of
    '-234': frame_from = 'STAPLANE'
    '-235': frame_from = 'STBPLANE'
    else: begin
        message = 'Unable to recognize spacecraft specification'
        goto, handle_error
    end
endcase
;
;  Do the same thing for the TO system.
;
base_to = to
if to eq 'MAG' then base_to = 'GEO'
if (to eq 'GSM') or (to eq 'SM') then base_to = 'GSE'
;
if (to eq 'HGRTN') or (to eq 'RTN') then case sc of
    '-234': frame_to = 'STAHGRTN'
    '-235': frame_to = 'STBHGRTN'
    '-21':  frame_to = 'SOHOHGRTN'
    '-144': frame_to = 'SOLOHGRTN'
    '-96':  frame_to = 'SPPHGRTN'
    else: begin
        if not !quiet then print, 'Assuming Earth observation'
        frame_to = 'GEORTN'
    end
endcase
;
if (to eq 'SCI') then case sc of
    '-234': frame_to = 'STASCPNT'
    '-235': frame_to = 'STBSCPNT'
    else: begin
        message = 'Unable to recognize spacecraft specification'
        goto, handle_error
    end
endcase
;
if (to eq 'HERTN') then case sc of
    '-234': frame_to = 'STAHERTN'
    '-235': frame_to = 'STBHERTN'
    '-21':  frame_to = 'SOHOHERTN'
    '-144': frame_to = 'SOLOHERTN'
    '-96':  frame_to = 'SPPHERTN'
    else: begin
        message = 'Unable to recognize spacecraft specification'
        goto, handle_error
    end
endcase
;
if (to eq 'STPLN') then case sc of
    '-234': frame_to = 'STAPLANE'
    '-235': frame_to = 'STBPLANE'
    else: begin
        message = 'Unable to recognize spacecraft specification'
        goto, handle_error
    end
endcase
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
;  From the base systems, determine the reference frames, and origins.
;
case strupcase(base_from) of
    'GEI': begin & frame_from = 'J2000'     & origin_from = 'Earth' & end
    'GEO': begin & frame_from = earth_frame & origin_from = 'Earth' & end
    'GSE': begin & frame_from = 'GSE'       & origin_from = 'Earth' & end
    'GAE': begin
        if keyword_set(precess) then frame_from = 'ECLIPDATE' else $
          frame_from = 'ECLIPJ2000'
        origin_from = 'Earth'
        end
    'HCI': begin & frame_from = 'HCI'       & origin_from = 'Sun'   & end
    'HAE': begin
        if keyword_set(precess) then frame_from = 'ECLIPDATE' else $
          frame_from = 'ECLIPJ2000'
        origin_from = 'Sun'
        end
    'HEE': begin & frame_from = 'HEE'       & origin_from = 'Sun'   & end
    'HEEQ': begin& frame_from = 'HEEQ'      & origin_from = 'Sun'   & end
    'CARRINGTON': begin & frame_from = 'IAU_SUN' & origin_from = 'Sun' & end
    'HGRTN': origin_from = 'Sun'
    'RTN': origin_from = sc
    'GRTN': begin & frame_from = 'GEORTN'   & origin_from = 'Earth' & end
    'SCI': origin_from = sc
    'HERTN': origin_from = 'Sun'
    'STPLN': origin_from = 'Sun'
    else: begin
        message = 'Unrecognized coordinate system'
        goto, handle_error
    endelse
endcase
;
case strupcase(base_to) of
    'GEI': begin & frame_to = 'J2000'     & origin_to = 'Earth' & end
    'GEO': begin & frame_to = earth_frame & origin_to = 'Earth' & end
    'GSE': begin & frame_to = 'GSE'       & origin_to = 'Earth' & end
    'GAE': begin
        if keyword_set(precess) then frame_to = 'ECLIPDATE' else $
          frame_to = 'ECLIPJ2000'
        origin_to = 'Earth'
        end
    'HCI': begin & frame_to = 'HCI'       & origin_to = 'Sun'   & end
    'HAE': begin
        if keyword_set(precess) then frame_to = 'ECLIPDATE' else $
          frame_to = 'ECLIPJ2000'
        origin_to = 'Sun'
        end
    'HEE': begin & frame_to = 'HEE'       & origin_to = 'Sun'   & end
    'HEEQ': begin& frame_to = 'HEEQ'      & origin_to = 'Sun'   & end
    'CARRINGTON': begin & frame_to = 'IAU_SUN' & origin_to = 'Sun' & end
    'HGRTN': origin_to = 'Sun'
    'RTN': origin_to = sc
    'GRTN': begin & frame_to = 'GEORTN'   & origin_to = 'Earth' & end
    'SCI': origin_to = sc
    'HERTN': origin_to = 'Sun'
    'STPLN': origin_to = 'Sun'
    else: begin
        message = 'Unrecognized coordinate system'
        goto, handle_error
    endelse
endcase
;
;  If the FROM and TO origins are different, first do an origin conversion.
;
if (origin_from ne origin_to) and (not keyword_set(ignore_origin)) then begin
    cspice_spkezr, origin_to, et, frame_from, 'None', origin_from, origin, $
      ltime
    if n_vec eq 3 then origin = origin[0:2,*,*,*,*,*,*,*]
    if (n_date eq 1) and (n_coord gt 1) then $
      origin = origin # replicate(1, n_coord)
    if keyword_set(meters) then origin = origin*1000 else $
      if keyword_set(au) then origin = origin / 1.4959787D8
    coord = coord - origin
endif
;
;  Calculate the transformation matrix, and apply it to the data.
;
case n_vec of
    3: cspice_pxform, frame_from, frame_to, et, xform
    6: cspice_sxform, frame_from, frame_to, et, xform
endcase
if n_date eq 1 then coord = transpose(xform) # coord else $
  for i = 0L,n_coord-1 do coord[*,i] = transpose(xform[*,*,i]) # coord[*,i]
;
;  If necessary, convert from BASE_TO to TO.
;
message = ''
if to eq 'MAG' then convert_sunspice_geo2mag, utc, coord, errmsg=message
if to eq 'GSM' then convert_sunspice_gse2gsm, utc, coord, errmsg=message, itrf93=itrf93
if to eq 'SM'  then convert_sunspice_gse2sm,  utc, coord, errmsg=message, itrf93=itrf93
if message ne '' then goto, handle_error
;
;  If necessary, restore COORD to its original dimensions.
;
if sz[0] gt 2 then coord = reform(coord, [n_vec,sz[2:sz[0]]], /overwrite)
return
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message else $
  errmsg = 'CONVERT_SUNSPICE_COORD: ' + message
;
end
