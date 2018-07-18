;+
; Project     :	Multimission
;
; Name        :	LOAD_SUNSPICE_EARTH
;
; Purpose     :	Load the PCK kernel files needed for ITRF93 coordinates
;
; Category    :	SUNSPICE, Orbit
;
; Explanation : Loads the SPICE Earth PCK kernels needed to support ITRF93
;               coordinates.  These are used when generating beacon station
;               ephemerides for STEREO, but could be used for other purposes as
;               well.  Also calls LOAD_SUNSPICE_GEN to load the generic SPICE
;               kernels.
;
;               A cron job keeps the Earth PCK kernels up-to-date.
;
; Syntax      :	LOAD_SUNSPICE_EARTH
;
; Inputs      :	None.
;
; Opt. Inputs :	None.
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	RELOAD = If set, then unload the current ephemeris files, and
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
;                               LOAD_SUNSPICE_EARTH, ERRMSG=ERRMSG
;                               IF ERRMSG NE '' THEN ...
;
; Calls       :	CONCAT_DIR, CSPICE_FURNSH, FILE_EXIST, TEST_SUNSPICE_DLM,
;               UNLOAD_SUNSPICE_EARTH, LOAD_SUNSPICE_GEN
;
; Common      :	SUNSPICE_EARTH contains the names of the loaded files, for
;               use by UNLOAD_SUNSPICE_EARTH.
;
; Env. Vars.  : Uses the environment variable SSW_SUNSPICE_GEN.
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
pro load_sunspice_earth, reload=reload, verbose=verbose, errmsg=errmsg
common sunspice_earth, earth_pck
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
n_kernels = n_elements(earth_pck)
if (not keyword_set(reload)) and (n_kernels gt 0) then return
;
;  Start by unloading any ephemerides which were previously loaded, and then
;  loading the generic kernels.
;
unload_sunspice_earth, verbose=verbose
message = ''
load_sunspice_gen, verbose=verbose, errmsg=message
if message ne '' then goto, handle_error
;
;  Load the Earth PCK kernels.
;
ssw_sunspice_gen = getenv('SSW_SUNSPICE_GEN')
file = concat_dir(ssw_sunspice_gen, 'naif_earth.dat')
path = concat_dir(ssw_sunspice_gen, 'earth')
openr, unit, file, /get_lun
while not eof(unit) do begin
    line = 'String'
    readf, unit, line
    line = strtrim(line,2)
    if (line ne '') and (strmid(line,0,1) ne '#') then begin
        file = concat_dir(path, line)
        if not file_exist(file) then begin
            message = 'Unable to open file ' + file
            goto, handle_error
        endif
        cspice_furnsh, file
        if keyword_set(verbose) then print, 'Loaded ' + file
        if n_elements(earth_pck) eq 0 then earth_pck = file else $
          earth_pck = [earth_pck, file]
    endif
endwhile
free_lun, unit
return
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message else $
  errmsg = 'LOAD_SUNSPICE_EARTH: ' + message
;
end
