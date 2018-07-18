;+
; Project     :	Multimission
;
; Name        :	GET_SUNSPICE_CMAT
;
; Purpose     :	Returns the pointing C-matrix of a spacecraft
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	This routine returns the orientation C-matrix of a spacecraft
;               in a wide variety of coordinate systems.
;
; Syntax      :	Cmat = GET_SUNSPICE_CMAT( DATE, SPACECRAFT )
;
; Examples    :	Cmat = GET_SUNSPICE_CMAT( '2006-05-06T11:30:00', 'STEREO-A' )
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
; Outputs     : The result of the function is the 3x3 transformation matrix,
;               which converts a vector from the specified reference frame to
;               the spacecraft/instrument reference frame.  This can be applied
;               to coordinate 3-vectors via one of the following commands:
;
;                     vec_inst = cmat ## vec_ref              ;; column vector
;                        or
;                     vec_inst = transpose(cmat) # vec_ref    ;; row vector
;                        or
;                     cspice_mxv, cmat, vec_ref, vec_inst     ;; row vector
;
;               Alternatively, to convert from the spacecraft/instrument
;               reference frame to the specified reference frame, use one of
;               the following commands:
;
;                     vec_ref = transpose(cmat) ## vec_inst   ;; column vector
;                        or
;                     vec_ref = cmat # vec_inst               ;; row vector
;                        or
;                     cspice_mxv, transpose(cmat), vec_inst, vec_ref
;                                                             ;; row vector
;
;               If DATE is a vector, then the result will have additional
;               dimensions.
;
; Opt. Outputs:	None.
;
; Keywords    : SIX_VECTOR = If set, then CMAT is returned as a 6x6 matrix,
;                            which can be applied to 6-vectors with both
;                            position and velocity information.
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
;                               HCI     Heliocentric Inertial
;                               HAE     Heliocentric Aries Ecliptic
;                               HEE     Heliocentric Earth Ecliptic
;                               HEEQ    Heliocentric Earth Equatorial (or HEQ)
;                               Carrington (can be abbreviated)
;                               HGRTN   Heliocentric Radial-Tangential-Normal
;                               RTN     Radial-Tangential-Normal (default)
;                               HPC     Helioprojective-Cartesian
;                               SCI     STEREO Science Pointing
;                               HERTN   Heliocentric Ecliptic RTN
;                               STPLN   STEREO Mission Plane
;
;                        Case is not important.
;
;               PRECESS = If set, then ecliptic coordinates are precessed from
;                         the J2000 reference frame to the mean ecliptic of
;                         date.  Only used for HAE/GAE.  Default is PRECESS=0.
;                         GSE and HEE use the ecliptic of date by definition.
;
;               TOLERANCE = The tolerance to be used when looking for pointing
;                            information, in seconds.  The default is 1000.
;
;               FOUND  = Byte array containing whether or not the pointings
;                        were found.
;
;               NOMINAL= If this keyword is set, the attitude history files are
;                        bypassed, and a nominal pointing is calculated from
;                        the ephemerides.
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
;                               Cmat = GET_SUNSPICE_CMAT( ERRMSG=ERRMSG, ... )
;                               IF ERRMSG NE '' THEN ...
;
;               Will also accept any LOAD_SUNSPICE or ANYTIM2UTC keywords.
;
; Calls       :	ANYTIM2UTC, CONCAT_DIR, CSPICE_STR2ET, CSPICE_SCE2C,
;               CSPICE_CKGP, LOAD_SUNSPICE, PARSE_SUNSPICE_NAME,
;               LOAD_SUNSPICE_ATT, CONVERT_SUNSPICE_GEO2MAG,
;               CONVERT_SUNSPICE_GSE2GSM, CONVERT_SUNSPICE_GSE2SM
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
; Prev. Hist. :	Based on GET_STEREO_CMAT
;
; History     :	Version 1, 26-Apr-2016, William Thompson, GSFC
;               Version 2, 29-Jun-2016, WTT, added ITRF93 keyword
;
; Contact     :	WTHOMPSON
;-
;
function get_sunspice_cmat, date, spacecraft, system=k_system, found=found, $
                            precess=precess, instrument=instrument, $
                            tolerance=tolerance, six_vector=six_vector, $
                            nominal=nominal, errmsg=errmsg, itrf93=itrf93, _extra=_extra
;
on_error, 2
if n_params() ne 2 then begin
    message = 'Syntax:  Cmat = GET_SUNSPICE_CMAT( DATE, SPACECRAFT )'
    goto, handle_error
endif
;
;  Determine which spacecraft was requested, and translate it into the proper
;  input for SPICE.
;
inst = 0L
sc = parse_sunspice_name(spacecraft)
;
if not valid_num(sc) then begin
    message = 'Unable to recognize spacecraft ' + strtrim(sc,2)
    goto, handle_error
endif
;
;  From the spacecraft code, determine the default instrument code.
;
sc = long(sc)
inst = sc*1000L
;
;  Modify the instrument code based on the specific sub-instrument.
;
if n_elements(instrument) ne 0 then print, $
  'INSTRUMENT keyword not yet implemented'
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
load_sunspice, sc, errmsg=message, _extra=_extra
if message ne '' then goto, handle_error
load_sunspice_att, sc, utc, errmsg=message, _extra=_extra
if message ne '' then goto, handle_error
;
;  Determine which coordinate system was specified.
;
if n_elements(k_system) eq 1 then system=strupcase(k_system) else system='RTN'
if system eq 'HEQ' then system = 'HEEQ'
if system eq strmid('CARRINGTON',0,strlen(system)) then system = 'CARRINGTON'
;
if (system eq 'HGRTN') or (system eq 'RTN') or (system eq 'HPC') then $
  case sc of
    -234: frame = 'STAHGRTN'
    -235: frame = 'STBHGRTN'
    else: begin
        message = 'No available frame definition'
        goto, handle_error
    end
endcase
;
if (system eq 'SCI') then case sc of
    -234: frame = 'STASCPNT'
    -235: frame = 'STBSCPNT'
    else: begin
        message = 'No available frame definition'
        goto, handle_error
    end
endcase
;
if (system eq 'HERTN') then case sc of
    -234: frame = 'STAHERTN'
    -235: frame = 'STBHERTN'
    else: begin
        message = 'No available frame definition'
        goto, handle_error
    end
endcase
;
if (system eq 'STPLN') then case sc of
    -234: frame = 'STAPLANE'
    -235: frame = 'STBPLANE'
    else: begin
        message = 'No available frame definition'
        goto, handle_error
    end
endcase
;
;  Determine the tolerance to be used when looking for the pointing
;  information.
;
if n_elements(tolerance) eq 1 then tol = tolerance else tol = 1000
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
;  Convert the date/time to ephemeris time, and then to spacecraft clock double
;  precision time.
;
cspice_str2et, utc, et
n = n_elements(et)
sz = size(et)
if keyword_set(six_vector) then n_vec=6 else n_vec=3
if sz[0] eq 0 then dim=[n_vec,n_vec] else dim=[n_vec,n_vec,sz[1:sz[0]]]
cmat = make_array(dimension=[n_vec,n_vec,n],/double)
found = bytarr(n)
for i=0L,n-1L do begin
    cspice_sce2c, sc, et[i], sclkdp
;
;  Based on the coordinate system requested, get the transformation matrix.
;
    case system of
        'GEI': frame = 'J2000'
        'GEO': frame = earth_frame
        'MAG': frame = earth_frame
        'GSE': frame = 'GSE'
        'GSM': frame = 'GSE'
        'SM':  frame = 'GSE'
        'GAE': if keyword_set(precess) then frame='ECLIPDATE' else $
          frame='ECLIPJ2000'
        'HCI': frame = 'HCI'
        'HAE': if keyword_set(precess) then frame='ECLIPDATE' else $
          frame='ECLIPJ2000'
        'HEE': frame = 'HEE'
        'HEEQ': frame = 'HEEQ'
        'CARRINGTON': frame = 'IAU_SUN'
        'HGRTN': frame = frame
        'RTN': frame = frame
        'HPC': frame = frame
        'SCI': frame = frame
        'HERTN': frame = frame
        'STPLN': frame = frame
        else: begin
            message = 'Unrecognized coordinate system'
            goto, handle_error
        endelse
    endcase
    if keyword_set(nominal) then ffound=0 else $
      cspice_ckgp,inst,sclkdp,tol,frame,ccmat,clkout,ffound
;
;  If the C-matrix was not found, then calculate a predicted C-matrix.
;
    if not ffound then begin
        ccmat = [[1.d0, 0, 0], [0, 1.d0, 0], [0, 0, 1.d0]]
        if system ne 'SCI' then begin
            case sc of
                -234: frame_from = 'STASCPNT'
                -235: frame_from = 'STBSCPNT'
                else: begin
                    message = 'No available frame definition for prediction'
                    goto, handle_error
                end
            endcase
            cspice_pxform, frame_from, frame, et[i], xform
            ccmat = transpose(xform) # ccmat
        endif
    endif
;
;  Apply any additional processing.
;
    case system of
        'MAG': convert_sunspice_geo2mag, utc[i], ccmat, /cmat
        'GSM': convert_sunspice_gse2gsm, utc[i], ccmat, /cmat, itrf93=itrf93
        'SM':  convert_sunspice_gse2sm,  utc[i], ccmat, /cmat, itrf93=itrf93
        'HPC': ccmat = ccmat ## [[0, 0, 1d0], [1.d0, 0, 0], [0, 1.d0, 0]]
        else:
    endcase
;
;  Store the C-matrix and the found state in the output arrays.
;
    cmat[0:2,0:2,i] = ccmat
    if keyword_set(six_vector) then cmat[3:5,3:5,i] = ccmat
    found[i] = ffound
endfor
;
;  Reformat the output arrays to match the input date/time array.
;
if n eq 1 then begin
    cmat = reform(cmat, /overwrite)
    found = found[0]
end else begin
    cmat = reform(cmat, dim, /overwrite)
    found = reform(found, dim[2:*], /overwrite)
endelse
;
return, cmat
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message else $
  errmsg = 'GET_SUNSPICE_CMAT: ' + message
;
end
