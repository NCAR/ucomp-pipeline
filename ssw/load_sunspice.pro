;+
; Project     :	Multimission
;
; Name        :	LOAD_SUNSPICE
;
; Purpose     :	Load spacecraft SPICE ephemeris and attitude kernels
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	Front-end routine to load the spacecraft ephemeris and attitude
;               history files in SPICE format, based on the specified
;               spacecraft name or NAIF code.  Also calls LOAD_SUNSPICE_GEN to
;               load the supporting kernels.
;
; Syntax      :	LOAD_SUNSPICE, SPACECRAFT
;
; Inputs      :	SPACECRAFT = The name or NAIF numeric code of the spacecraft.
;                            See PARSE_SUNSPICE_NAME for more information about
;                            recognized names.
;
;                            Note that for missions consisting of multiple
;                            spacecraft, such as STEREO, the name of a specific
;                            spacecraft must be specified, rather than the name
;                            of the mission, e.g.
;
;                               LOAD_SUNSPICE, 'STEREO AHEAD'     [OK]
;                               LOAD_SUNSPICE, 'STEREO'           [Fails]
;
;                            Passing the name of either STEREO spacecraft will
;                            load the ephemerides for both spacecraft.
;
; Opt. Inputs :	None
;
; Outputs     :	None
;
; Opt. Outputs:	None
;
; Keywords    :	See the individual mission-specific routines for information
;               about supported keywords.
;
;               ERRMSG = If defined and passed, then any error messages will be
;                        returned to the user in this parameter rather than
;                        depending on the MESSAGE routine in IDL.  If no errors
;                        are encountered, then a null string is returned.  In
;                        order to use this feature, ERRMSG must be defined
;                        first, e.g.
;
;                               ERRMSG = ''
;                               LOAD_SUNSPICE, spacecraft, ERRMSG=ERRMSG
;                               IF ERRMSG NE '' THEN ...
;
; Calls       :	LOAD_SUNSPICE_GEN, TEST_SUNSPICE_DLM, PARSE_SUNSPICE_NAME,
;               LOAD_SUNSPICE_STEREO
;
; Common      :	None
;
; Env. Vars.  : None
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
; Side effects:	None
;
; Prev. Hist. :	None
;
; History     :	Version 1, 25-Apr-2016, William Thompson, GSFC
;               Version 2, 06-Feb-2017, WTT, support Solar Orbiter (-144)
;               Version 3, 27-Feb-2017, WTT, use catch instead of which
;               Version 4, 24-Mar-2017, WTT, support Solar Probe Plus (-96)
;
; Contact     :	WTHOMPSON
;-
;
pro load_sunspice, spacecraft, errmsg=errmsg, _extra=_extra
on_error, 2
if n_params() ne 1 then begin
    message = 'A spacecraft name must be passed.'
    goto, handle_error
endif
;
;  Make sure that the SPICE/Icy DLM is available.
;
if not test_sunspice_dlm() then begin
    message = 'SPICE/Icy DLM not available'
    goto, handle_error
endif
;
;  Make sure that the generic SPICE kernels are available.
;
message = ''
load_sunspice_gen, errmsg=message, _extra=_extra
if message ne '' then goto, handle_error
;
;  Parse the spacecraft name, and act accordingly.
;
sc = parse_sunspice_name(spacecraft)
message = ''
case sc of
    '-234': begin
        catch, error_status
        if error_status ne 0 then begin
            message = 'LOAD_SUNSPICE_STEREO not found'
            break
        endif
        load_sunspice_stereo, errmsg=message, _extra=_extra
    end
    '-235': begin
        catch, error_status
        if error_status ne 0 then begin
            message = 'LOAD_SUNSPICE_STEREO not found'
            break
        endif
        load_sunspice_stereo, errmsg=message, _extra=_extra
    end
    '-21': begin
        catch, error_status
        if error_status ne 0 then begin
            message = 'LOAD_SUNSPICE_SOHO not found'
            break
        endif
        load_sunspice_soho, errmsg=message, _extra=_extra
    end
    '-144': begin
        catch, error_status
        if error_status ne 0 then begin
            message = 'LOAD_SUNSPICE_SOLO not found'
            break
        endif
        load_sunspice_solo, errmsg=message, _extra=_extra
    end
    '-96': begin
        catch, error_status
        if error_status ne 0 then begin
            message = 'LOAD_SUNSPICE_SPP not found'
            break
        endif
        load_sunspice_spp, errmsg=message, _extra=_extra
    end
    else: 
endcase
catch, /cancel
if message ne '' then goto, handle_error
;
return
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message else $
  errmsg = 'LOAD_SUNSPICE: ' + message
;
end
