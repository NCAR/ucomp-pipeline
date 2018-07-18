;+
; Project     :	Multimission
;
; Name        :	LOAD_SUNSPICE_ATT
;
; Purpose     :	Load spacecraft SPICE ephemeris and attitude kernels
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	Called from GET_SUNSPICE_CMAT to provide "on demand" loading of
;               the spacecraft attitude history files in SPICE format.  This
;               routine is a front-end to mission-specific routines such as
;               LOAD_SUNSPICE_ATT_STEREO.
;
; Syntax      :	LOAD_SUNSPICE_ATT, SPACECRAFT, DATE
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
;                               LOAD_SUNSPICE_ATT, 'STEREO AHEAD'     [OK]
;                               LOAD_SUNSPICE_ATT, 'STEREO'           [Fails]
;
;                            Only the appropriate attitude history file(s) for
;                            that satellite will be loaded.
;
;               DATE       = One or more date/time values.
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
;                               LOAD_SUNSPICE_ATT, spacecraft, ERRMSG=ERRMSG
;                               IF ERRMSG NE '' THEN ...
;
; Calls       :	LOAD_SUNSPICE, TEST_SUNSPICE_DLM, PARSE_SUNSPICE_NAME,
;               LOAD_SUNSPICE_ATT_STEREO
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
; History     :	Version 1, 26-Apr-2016, William Thompson, GSFC
;               Version 2, 27-Feb-2017, WTT, use catch instead of which
;
; Contact     :	WTHOMPSON
;-
;
pro load_sunspice_att, spacecraft, date, errmsg=errmsg, _extra=_extra
on_error, 2
if n_params() ne 2 then begin
    message = 'A spacecraft name and date must be passed.'
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
;  Parse the spacecraft name, and act accordingly.
;
sc = parse_sunspice_name(spacecraft)
message = ''
case sc of
    '-234': begin
        catch, error_status
        if error_status ne 0 then begin
            message = 'LOAD_SUNSPICE_STEREO not found'
            catch, /cancel
            goto, handle_error
        endif
        load_sunspice_stereo, errmsg=message, _extra=_extra
        if message ne '' then goto, handle_error
        load_sunspice_att_stereo, sc, date, _extra=_extra
    end
    '-235': begin
        catch, error_status
        if error_status ne 0 then begin
            message = 'LOAD_SUNSPICE_STEREO not found'
            catch, /cancel
            goto, handle_error
        endif
        load_sunspice_stereo, errmsg=message, _extra=_extra
        if message ne '' then goto, handle_error
        load_sunspice_att_stereo, sc, date, _extra=_extra
    end
    else: begin
        message = 'No available attitude files'
        goto, handle_error
    end
endcase
;
return
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message else $
  errmsg = 'LOAD_SUNSPICE_ATT: ' + message
;
end
