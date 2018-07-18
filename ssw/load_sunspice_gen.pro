;+
; Project     :	Multimission
;
; Name        :	LOAD_SUNSPICE_GEN
;
; Purpose     :	Load the generic SPICE kernels
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	Loads the generic SPICE kernels needed to process ephemerides
;               and attitude history files for various missions.  This
;               procedure seeks out and loads the following files from the
;               SolarSoft tree:
;
;                   * A leapseconds file                (e.g. naif0011.tls)
;                   * A solar system ephemeris          (e.g. de405.bsp)
;                   * A planetary constants file        (e.g. pck00010.tpc)
;                   * The frame file heliospheric.tf
;
; Syntax      :	LOAD_SUNSPICE_GEN
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
;               PLANETARY = Specifies which planetary ephemeris should be
;                           loaded, e.g. PLANETARY='de405.bsp'.  Only ephemeris
;                           files in the $SSW_SUNSPICE_GEN directory can be
;                           loaded via this keyword.  The default is to load
;                           the highest numbered ephemeris file.  Ignored if
;                           the generic ephemerides are already loaded, unless
;                           /RELOAD is set.
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
;                               LOAD_SUNSPICE_GEN, ERRMSG=ERRMSG
;                               IF ERRMSG NE '' THEN ...
;
; Calls       :	CONCAT_DIR, CSPICE_FURNSH, UNLOAD_SUNSPICE_GEN,
;               TEST_SUNSPICE_DLM
;
; Common      :	GEN_SUNSPICE contains the names of the loaded files, for use by
;               UNLOAD_SUNSPICE_GEN.
;
; Env. Vars.  : SSW_SUNSPICE_GEN points to the location of the generic kernels.
;               If not defined, defaults to $SSW/packages/sunspice/data.
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
; Prev. Hist. :	Based on LOAD_STEREO_SPICE_GEN
;
; History     :	Version 1, 22-Apr-2016, William Thompson, GSFC
;
; Contact     :	WTHOMPSON
;-
;
pro load_sunspice_gen, reload=reload, verbose=verbose, planetary=planetary, errmsg=errmsg
common gen_sunspice, leapsec, solarsys, planet_const, helioframe
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
if (not keyword_set(reload)) and (n_elements(leapsec) gt 0) and $
  (n_elements(solarsys) gt 0) and (n_elements(planet_const) gt 0) and $
  (n_elements(helioframe) gt 0) then return
;
;  Start by unloading any kernels previously loaded by this routine.
;
unload_sunspice_gen, verbose=verbose
;
;  Get the directory containing the generic kernels.
;
ssw_sunspice_gen = getenv('SSW_SUNSPICE_GEN')
if ssw_sunspice_gen eq '' then begin
    ssw_sunspice_gen = getenv('SSW')
    ssw_sunspice_gen = concat_dir(ssw_sunspice_gen, 'packages')
    ssw_sunspice_gen = concat_dir(ssw_sunspice_gen, 'sunspice')
    ssw_sunspice_gen = concat_dir(ssw_sunspice_gen, 'data')
endif
if !version.os_family eq 'Windows' then $
  ssw_sunspice_gen = concat_dir(ssw_sunspice_gen, 'dos')
;
;  Load the leap-seconds file.
;
files = file_search( concat_dir(ssw_sunspice_gen, 'naif*.tls'), count=count)
if count eq 0 then begin
    message = 'Unable to find leap-seconds file'
    goto, handle_error
endif
leapsec = max(files)
if keyword_set(verbose) then print, 'Loaded ' + leapsec
cspice_furnsh, leapsec
;
;  Load the solar system ephmeris.
;
if (datatype(planetary) eq 'STR') and (n_elements(planetary) eq 1) then $
  testfile = form_filename( planetary, '.bsp') else testfile='de*.bsp'
files = file_search( concat_dir(ssw_sunspice_gen, testfile), count=count)
if count eq 0 then begin
    message = 'Unable to find planetary ephemeris file'
    goto, handle_error
endif
solarsys = max(files)
if keyword_set(verbose) then print, 'Loaded ' + solarsys
cspice_furnsh, solarsys
;
;  Load the planetary constants file.
;
files = file_search( concat_dir(ssw_sunspice_gen, 'pck*.tpc'), count=count)
if count eq 0 then begin
    message = 'Unable to find planetary constants file'
    goto, handle_error
endif
planet_const = max(files)
if keyword_set(verbose) then print, 'Loaded ' + planet_const
cspice_furnsh, planet_const
;
;  Load the heliospheric frames file
;
helioframe = concat_dir(ssw_sunspice_gen, 'heliospheric.tf')
if not file_exist(helioframe) then begin
    message = 'Unable to find heliospheric frame file'
    goto, handle_error
endif
if keyword_set(verbose) then print, 'Loaded ' + helioframe
cspice_furnsh, helioframe
;
return
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message else $
  errmsg = 'LOAD_SUNSPICE_GEN: ' + message
;
end
