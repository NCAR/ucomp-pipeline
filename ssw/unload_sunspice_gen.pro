;+
; Project     :	Multimission
;
; Name        :	UNLOAD_SUNSPICE_GEN
;
; Purpose     :	Unload the generic SPICE kernels
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	Unloads the general SPICE kernels previously loaded by
;               LOAD_SUNSPICE_GEN.
;
; Syntax      :	UNLOAD_SUNSPICE_GEN
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
; Common      :	GEN_SUNSPICE contains the names of the loaded files.
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
; Prev. Hist. :	Based on UNLOAD_STEREO_SPICE_GEN
;
; History     :	Version 1, 22-Apr-2016, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro unload_sunspice_gen, verbose=verbose
common gen_sunspice, leapsec, solarsys, planet_const, helioframe
on_error, 2
;
;  Unload the files.
;
if n_elements(leapsec) eq 1 then begin
    cspice_unload, leapsec
    if keyword_set(verbose) then print, 'Unloaded ' + leapsec
    delvarx, leapsec
endif
;
if n_elements(solarsys) eq 1 then begin
    cspice_unload, solarsys
    if keyword_set(verbose) then print, 'Unloaded ' + solarsys
    delvarx, solarsys
endif
;
if n_elements(planet_const) eq 1 then begin
    cspice_unload, planet_const
    if keyword_set(verbose) then print, 'Unloaded ' + planet_const
    delvarx, planet_const
endif
;
if n_elements(helioframe) eq 1 then begin
    cspice_unload, helioframe
    if keyword_set(verbose) then print, 'Unloaded ' + helioframe
    delvarx, helioframe
endif
;
end
