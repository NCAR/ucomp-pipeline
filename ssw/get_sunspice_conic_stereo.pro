;+
; Project     :	STEREO - SSC
;
; Name        :	GET_SUNSPICE_CONIC_STEREO
;
; Purpose     :	Get the conic parameters for STEREO A or B
;
; Category    :	STEREO, SUNSPICE, Orbit
;
; Explanation :	Returns the conic parameters describing the orbit of one of the
;               STEREO spacecraft at the end of the available predictive
;               ephemeris files.  These parameters allow the orbit to be
;               projected beyond the end of the SPICE kernels.
;
;               Normally called from GET_SUNSPICE_CONIC.
;
; Syntax      :	GET_SUNSPICE_CONIC_STEREO, SPACECRAFT, MAXDATE, CONIC
;
; Inputs      :	SPACECRAFT = The name or NAIF numeric code of one of the two
;                            STEREO spacecraft.  See PARSE_SUNSPICE_NAME for more
;                            information about recognized names.
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
; Calls       :	LOAD_SUNSPICE_STEREO, PARSE_SUNSPICE_NAME, DELVARX
;
; Common      :	STEREO_SUNSPICE contains the names of the loaded files, for
;               use by UNLOAD_SUNSPICE_STEREO.  It also contains the conic
;               parameters for projecting beyond the end of the orbit files.
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
; Side effects:	If SPACECRAFT does not translate to one of the two STEREO
;               spacecraft, or no conic parameters are found, then MAXDATE and
;               CONIC are returned as undefined.
;
; Prev. Hist. :	None
;
; History     :	Version 1, 25-Apr-2016, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro get_sunspice_conic_stereo, spacecraft, sc_maxdate, sc_conic
;
common stereo_sunspice, rtnframe, clocks, def_ephem, ephem, attitude, att_sc, $
  att_mjd, att_loaded, mu, maxdate, conic
on_error, 2
;
load_sunspice_stereo
;
if n_elements(mu) eq 1 then begin
    sc = parse_sunspice_name(spacecraft)
    case sc of
        '-234': begin
            sc_maxdate = maxdate[0]
            sc_conic = conic[*,0]
        end
        '-235': begin
            sc_maxdate = maxdate[1]
            sc_conic = conic[*,1]
        end
        else: begin
            message, /continue, sc + $
                     ' not recognized as either of the STEREO spacecraft'
            delvarx, sc_maxdate, sc_conic
        end
    endcase
end else delvarx, sc_maxdate, sc_conic
;
return
end
