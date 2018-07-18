;+
; Project     :	Multimission
;
; Name        :	GET_SUNSPICE_RANGE
;
; Purpose     :	Retrieve the date range of a binary SPICE kernel
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	Calls CSPICE_SPKCOV or CSPICE_CKCOV to determine the range of
;               coverage of a binary SPICE kernel as used by the SunSPICE
;               program.
;
; Syntax      :	GET_SUNSPICE_RANGE, FILENAME, DATE0, DATE1  [, SCID ]
;
; Examples    :	FILE = 'behind_2006_114_02.epm.bsp'
;               GET_SUNSPICE_RANGE, FILE, DATE0, DATE1
;
; Inputs      :	FILENAME = The name of the file to examine
;
; Opt. Inputs :	None
;
; Outputs     :	DATE0, DATE1 = The beginning and end dates
;
; Opt. Outputs:	SCID   = Returns the spacecraft or body ID numbers found in the
;                        file, e.g. -234 for STEREO Ahead or -235 for STEREO
;                        Behind.  Note that ID numbers in Attitude History (CK)
;                        files have three extra digits, e.g. -234000.
;
; Keywords    :	TAI    = If set, the times are returned as TAI.  Otherwise, the
;                        times are returned as UTC.
;
;               ERRMSG = If defined and passed, then any error messages will be
;			 returned to the user in this parameter rather than
;			 depending on the MESSAGE routine in IDL.  If no errors
;			 are encountered, then a null string is returned.  In
;			 order to use this feature, ERRMSG must be defined
;			 first, e.g.
;
;				ERRMSG = ''
;				GET_SUNSPICE_RANGE, ERRMSG=ERRMSG, ...
;				IF ERRMSG NE '' THEN ...
;
;               Will also accept any keywords for LOAD_SUNSPICE_GEN, and
;               ANYTIM2UTC or UTC2TAI.
;
; Calls       :	LOAD_SUNSPICE_GEN, BREAK_FILE, CSPICE_CELLI, CSPICE_SPKOBJ,
;               CSPICE_SPKCOV, CSPICE_CKOBJ, CSPICE_CKCOV, CSPICE_ET2UTC,
;               UTC2TAI, ANYTIM2UTC
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	Will automatically load the generic SPICE ephemeris files, if
;               not already loaded.
;
;               If the file contains multiple objects, the time range will
;               represent all the objects in the file.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 1-Feb-2006, William Thompson, GSFC
;               Version 2, 6-Jul-2006, William Thompson, GSFC
;                       Support both INTERVAL and SEGMENT cases.
;               Version 3, 22-Apr-2016, William Thompson, GSFC
;                       Rename GET_STEREO_SPICE_RANGE to GET_SUNSPICE_RANGE
;
; Contact     :	WTHOMPSON
;-
;
pro get_sunspice_range, filename, date0, date1, scid, tai=tai, errmsg=errmsg, $
                      _extra=_extra
on_error, 2
;
;  Check the input parameters.
;
if n_params() lt 3 then begin
    message = 'Syntax: GET_SUNSPICE_RANGE, FILENAME, DATE0, DATE1  [, SC ]'
    goto, handle_error
endif
if datatype(filename,1) ne 'String' then begin
    message = 'FILENAME must be a character string'
    goto, handle_error
endif
if n_elements(filename) ne 1 then begin
    message, 'FILENAME must be scalar'
    goto, handle_error
endif
if not file_exist(filename) then begin
    message = 'File "' + filename + '" does not exist'
    goto, handle_error
endif
;
;  Make sure that the generic ephemeris files are loaded.
;
message = ''
load_sunspice_gen, errmsg=message, _extra=_extra
if message ne '' then goto, handle_error
;
;  Break the filename up into name and extension components.
;
break_file, filename, disk, dir, name, ext
;
;  Ephemeris files.
;
if strlowcase(strmid(ext,strlen(ext)-4,4)) eq '.bsp' then begin
;
;  Find the object IDs in the file.
;
    ids = cspice_celli(1000)
    cspice_spkobj, filename, ids
    scid = ids.base[ids.data:ids.data+ids.card-1]
    if n_elements(scid) eq 1 then scid = scid[0]
;
;  Step through the SCIDs, and extract the start and end times.
;
    delvarx, times
    cover = cspice_celld(2000)
    for i=0,n_elements(scid)-1 do begin
        cspice_spkcov, filename, scid[i], cover
        et = cover.base[cover.data:cover.data+cover.card-1]
        if n_elements(times) eq 0 then times = et else times = [times,et]
    endfor
;
;  Pointing files
;
end else if strlowcase(strmid(ext,strlen(ext)-3,3)) eq '.bc' then begin
;
;  Find the object IDs in the file.
;
    ids = cspice_celli(1000)
    cspice_ckobj, filename, ids
    scid = ids.base[ids.data:ids.data+ids.card-1]
    if n_elements(scid) eq 1 then scid = scid[0]
;
;  Step through the SCIDs, and extract the start and end times.
;
    delvarx, times
    cover = cspice_celld(2000)
    for i=0,n_elements(scid)-1 do begin
        catch, error_status
        if error_status ne 0 then begin
            cspice_ckcov, filename, scid[i], 0b, 'SEGMENT', 0.D, "TDB", cover
        end else begin
            cspice_ckcov, filename, scid[i], 0b, 'INTERVAL', 0.D, "TDB", cover
        endelse
        catch, /cancel
        et = cover.base[cover.data:cover.data+cover.card-1]
        if n_elements(times) eq 0 then times = et else times = [times,et]
    endfor
end else begin
    message = 'Unrecognized extension ' + ext
    goto, handle_error
endelse
;
;  Format the date/times as requested, and return.
;
cspice_et2utc, min(times), 'ISOC', 3, date0
cspice_et2utc, max(times), 'ISOC', 3, date1
if keyword_set(tai) then begin
    date0 = utc2tai(date0, _extra=_extra)
    date1 = utc2tai(date1, _extra=_extra)
end else begin
    date0 = anytim2utc(date0, _extra=_extra)
    date1 = anytim2utc(date1, _extra=_extra)
endelse
return
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) ne 0 then $
  errmsg = 'GET_SUNSPICE_RANGE: ' + message else $
  message, message
;
end
