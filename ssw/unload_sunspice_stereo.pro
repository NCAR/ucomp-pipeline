;+
; Project     :	STEREO - SSC
;
; Name        :	UNLOAD_SUNSPICE_STEREO
;
; Purpose     :	Unload the STEREO SPICE kernels
;
; Category    :	STEREO, SUNSPICE, Orbit
;
; Explanation :	Unloads any previously loaded SPICE kernels loaded by
;               LOAD_SUNSPICE_STEREO.
;
; Syntax      :	UNLOAD_SUNSPICE_STEREO
;
; Inputs      :	None
;
; Opt. Inputs :	None
;
; Outputs     :	None
;
; Opt. Outputs:	None
;
; Keywords    :	VERBOSE = If set, then print a message for each file unloaded.
;
; Calls       :	CSPICE_UNLOAD, DELVARX
;
; Common      :	STEREO_SPICE contains the names of the loaded files.
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
; Prev. Hist. :	Based on UNLOAD_STEREO_SPICE
;
; History     :	Version 1, 25-Apr-2016, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro unload_sunspice_stereo, verbose=verbose
;
common stereo_sunspice, rtnframe, clocks, def_ephem, ephem, attitude, att_sc, $
  att_mjd, att_loaded, mu, maxdate, conic
on_error, 2
;
;  Unload the files.
;
if n_elements(rtnframe) eq 1 then begin
    cspice_unload, rtnframe
    if keyword_set(verbose) then print, 'Unloaded ' + rtnframe
    delvarx, rtnframe
endif
;
if n_elements(clocks) ge 1 then begin
    for i=0,n_elements(clocks)-1 do begin
        cspice_unload, clocks[i]
        if keyword_set(verbose) then print, 'Unloaded ' + clocks[i]
    endfor
    delvarx, clocks
endif
;
if n_elements(def_ephem) ge 1 then begin
    for i=0,n_elements(def_ephem)-1 do begin
        cspice_unload, def_ephem[i]
        if keyword_set(verbose) then print, 'Unloaded ' + def_ephem[i]
    endfor
    delvarx, def_ephem
endif
;
if n_elements(ephem) ge 1 then begin
    for i=0,n_elements(ephem)-1 do begin
        cspice_unload, ephem[i]
        if keyword_set(verbose) then print, 'Unloaded ' + ephem[i]
    endfor
    delvarx, ephem
endif
;
if n_elements(attitude) ge 1 then begin
    for i=0,n_elements(attitude)-1 do begin
        cspice_unload, attitude[i]
        if keyword_set(verbose) then print, 'Unloaded ' + attitude[i]
    endfor
    delvarx, attitude, att_sc, att_mjd, att_loaded
endif
;
;  Undefine the conic parameters.
;
delvarx, mu, maxdate, conic
;
end
