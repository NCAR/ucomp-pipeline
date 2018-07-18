;+
; Project     :	SOHO
;
; Name        :	LOAD_SUNSPICE_SOHO
;
; Purpose     :	Load the SOHO SPICE ephemerides
;
; Category    :	SOHO, SUNSPICE, Orbit
;
; Explanation :	Loads the SOHO ephemeris files in SPICE format.  Also calls
;               LOAD_SUNSPICE_GEN to load the generic kernels.
;
; Syntax      :	LOAD_SUNSPICE_SOHO
;
; Inputs      :	None.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    : RELOAD = If set, then unload the current ephemeris files, and
;                        redetermine which kernels to load.  The default is to
;                        not reload already loaded kernels.
;
;               VERBOSE= If set, then print a message for each file loaded.
;
;               ERRMSG = If defined and passed, then any error messages will be
;                        returned to the user in this parameter rather than
;                        depending on the MESSAGE routine in IDL.  If no errors
;                        are encountered, then a null string is returned.  In
;                        order to use this feature, ERRMSG must be defined
;                        first, e.g.
;
;                               ERRMSG = ''
;                               LOAD_SUNSPICE_SOHO, ERRMSG=ERRMSG
;                               IF ERRMSG NE '' THEN ...
;
; Calls       :	TEST_SUNSPICE_DLM, LOAD_SUNSPICE, LIST_SUNSPICE_KERNELS, MATCH,
;               CSPICE_FURNSH
;
; Common      :	SOHO_SUNSPICE contains the names of the loaded files.
;
; Env. Vars.  : SOHO_SPICE points to the directory containing the SOHO SPICE
;               ephemerides (soho_*.bsp).
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
; Prev. Hist. :	Based on LOAD_SOHO_SPICE
;
; History     :	Version 1, 28-Apr-2016, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro load_sunspice_soho, reload=reload, verbose=verbose, errmsg=errmsg
common soho_sunspice, rtnframe, ephem
on_error, 2
;
;  Make sure that the SPICE/Icy DLM is available.
;
if not test_sunspice_dlm() then begin
    message = 'SPICE/Icy DLM not available'
    goto, handle_error
endif
;
;  If the /RELOAD keyword wasn't passed, then check to see if the kernels have
;  already been loaded.
;
n_kernels = n_elements(ephem)
if (not keyword_set(reload)) and (n_kernels gt 0) then return
;
;  Start by unloading any ephemerides which were previously loaded, and then
;  loading the generic kernels.
;
unload_sunspice_soho, verbose=verbose
message = ''
load_sunspice_gen, verbose=verbose, errmsg=message
if message ne '' then goto, handle_error
;
;  Load the RTN frame.
;
soho_spice_gen = getenv('SOHO_SPICE_GEN')
if !version.os_family eq 'Windows' then $
  soho_spice_gen = concat_dir(soho_spice_gen, 'dos')
;
rtnframe = concat_dir(soho_spice_gen, 'soho_rtn.tf')
if not file_exist(rtnframe) then begin
    message = 'Unable to find heliospheric frame file'
    goto, handle_error
endif
if keyword_set(verbose) then print, 'Loaded ' + rtnframe
cspice_furnsh, rtnframe
;
;  Get a list of all ephemeris files
;
soho_spice = getenv('SOHO_SPICE')
files = file_search(concat_dir(soho_spice, 'soho_*.bsp'), count=count)
if count eq 0 then begin
    message = 'No SOHO ephemeris files found'
    goto, handle_error
endif
ephem = files
;
;  Get a list of currently loaded kernels, and match it against the SOHO
;  ephemeris list.  Load any kernels not already loaded.
;
list_sunspice_kernels, kernels=kernels, /quiet
match, ephem, kernels, wephem, wkernels, count=count
if count ne n_elements(ephem) then for i=0,n_elements(ephem)-1 do begin
    w = where(ephem[i] eq kernels, count)
    if count eq 0 then begin
        cspice_furnsh, ephem[i]
        if keyword_set(verbose) then print, 'Loaded ' + ephem[i]
    endif
endfor
;
return
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message else $
  errmsg = 'LOAD_SUNSPICE_SOHO: ' + message
;
end
