;+
; Project     :	Multimission
;
; Name        :	GET_SUNSPICE_CONIC
;
; Purpose     :	Get the conic parameters for a spacecraft
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	Front-end to mission-specific software which returns the conic
;               parameters describing the orbit of a spacecraft at the end of
;               the available predictive ephemeris files.  These parameters
;               allow the orbit to be projected beyond the end of the SPICE
;               kernels.  This option must be supported by the mission's
;               SUNSPICE software, e.g. LOAD_SUNSPICE_STEREO,
;               GET_SUNSPICE_CONIC_STEREO.
;
;               As new missions are added with conic parameters, this routine
;               must be updated to recognize those missions.
;
;               Not applicable to HGRTN, RTN, HERTN, or SCI coordinate systems.
;
; Syntax      :	GET_SUNSPICE_CONIC, SPACECRAFT, MAXDATE, CONIC
;
; Inputs      :	SPACECRAFT = The name or NAIF numeric code of the spacecraft.
;                            See PARSE_SUNSPICE_NAME for more information about
;                            recognized names.
;
; Opt. Inputs :	None.
;
; Outputs     :	MAXDATE = The date at which the SPICE predictive ephemerides
;                         end, and the conic parameters take over.
;
;               CONIC   = The conic parameters for the orbit about the Sun, in
;                         the form used by CSPICE_CONICS.
;
; Opt. Outputs:	None
;
; Keywords    :	None
;
; Calls       :	PARSE_SUNSPICE_NAME, DELVARX, GET_SUNSPICE_CONIC_STEREO
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
; Side effects:	If no conic parameters are found, then MAXDATE and CONIC are
;               returned as undefined.
;
; Prev. Hist. :	None
;
; History     :	Version 1, 25-Apr-2016, William Thompson, GSFC
;               Version 2, 27-Feb-2017, WTT, use catch instead of which
;
; Contact     :	WTHOMPSON
;-
;
pro get_sunspice_conic, spacecraft, maxdate, conic
;
on_error, 2
;
sc = parse_sunspice_name(spacecraft)
delvarx, maxdate, conic
case sc of
    '-234': begin
        catch, error_status
        if error_status ne 0 then begin
            catch, /cancel
            return
        endif
        get_sunspice_conic_stereo, sc, maxdate, conic
    end
    '-235': begin
        catch, error_status
        if error_status ne 0 then begin
            catch, /cancel
            return
        endif
        get_sunspice_conic_stereo, sc, maxdate, conic
    end
    else:
endcase
;
return
end
