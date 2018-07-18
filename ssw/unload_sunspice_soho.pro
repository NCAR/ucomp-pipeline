;+
; Project     :	SOHO
;
; Name        :	UNLOAD_SUNSPICE_SOHO
;
; Purpose     :	Unload the SOHO SPICE kernels
;
; Category    :	SOHO, SUNSPICE, Orbit
;
; Explanation :	Unloads any previously loaded SPICE kernels loaded by
;               LOAD_SUNSPICE_SOHO.
;
; Syntax      :	UNLOAD_SUNSPICE_SOHO
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
; Common      :	SOHO_SUNSPICE contains the names of the loaded files.
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
; History     :	Version 1, 28-Apr-2016, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro unload_sunspice_soho, verbose=verbose
;
common soho_sunspice, rtnframe, ephem
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
if n_elements(ephem) ge 1 then begin
    for i=0,n_elements(ephem)-1 do begin
        cspice_unload, ephem[i]
        if keyword_set(verbose) then print, 'Unloaded ' + ephem[i]
    endfor
    delvarx, ephem
endif
;
end
