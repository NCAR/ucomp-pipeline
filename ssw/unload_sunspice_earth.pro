;+
; Project     :	Multimission
;
; Name        :	UNLOAD_SUNSPICE_EARTH
;
; Purpose     :	Unload the PCK kernel files needed for ITRF93 coordinates
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	Unloads any previously loaded SPICE Earth PCK kernels loaded by
;               LOAD_SUNSPICE_EARTH.
;
; Syntax      :	UNLOAD_SUNSPICE_EARTH
;
; Inputs      :	None.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	VERBOSE = If set, then print a message for each file unloaded.
;
; Calls       :	CSPICE_UNLOAD
;
; Common      :	SUNSPICE_EARTH contains the names of the loaded files.
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
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 14-Jun-2010, William Thompson, GSFC
;               Version 2, 27-May-2016, WTT, renamed from UNLOAD_STEREO_SPICE_EARTH
;
; Contact     :	WTHOMPSON
;-
;
pro unload_sunspice_earth, verbose=verbose
;
common sunspice_earth, earth_pck
on_error, 2
;
;  Unload the kernels listed in the common block.
;
if n_elements(earth_pck) gt 0 then for i=0,n_elements(earth_pck)-1 do begin
    cspice_unload, earth_pck[i]
    if keyword_set(verbose) then print, 'Unloaded ' + earth_pck[i]
endfor
delvarx, earth_pck
;
end
