;+
; Project     :	Multimission
;
; Name        :	GET_SUNSPICE_IGRF_POLE
;
; Purpose     :	Returns Earth's magnitude pole position by date.
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	This procedure calculates the centered dipole approximation of
;               the International Geomagnetic Reference Field (IGRF).  This
;               pole position, which varies with date, is used to define
;               various magnetic coordinate systems, such as Geocentric Solar
;               Magnetospheric (GSM).
;
;               The first time this routine is called, the coefficients are
;               read from the file igrf10coeffs.txt, and stored in a common
;               block for future calls.
;
; Syntax      :	GET_SUNSPICE_IGRF_POLE, DATE, THETA, PHI
;
; Examples    :	GET_SUNSPICE_IGRF_POLE, '2007-01-31', THETA, PHI
;
; Inputs      :	DATE = The date and time.  This can be input in any format
;                      accepted by ANYTIM2UTC, and can also be an array of
;                      values.
;
; Opt. Inputs :	None.
;
; Outputs     :	THETA,PHI = The pole latitude and longitude, in radians.  If
;                           DATE is an array, then these will also be arrays.
;
; Opt. Outputs:	None.
;
; Keywords    :	ERRMSG = If defined and passed, then any error messages will be
;                        returned to the user in this parameter rather than
;                        depending on the MESSAGE routine in IDL.  If no errors
;                        are encountered, then a null string is returned.  In
;                        order to use this feature, ERRMSG must be defined
;                        first, e.g.
;
;                               ERRMSG = ''
;                               GET_SUNSPICE_IGRF_POLE, DT, LN, LT, ERRMSG=ERRMSG
;                               IF ERRMSG NE '' THEN ...
;
; Calls       :	CONCAT_DIR, STR_SEP, ANYTIM2UTC, UTC2TAI, INTERPOL
;
; Common      :	Common block GET_SUNSPICE_IGRF_POLE contains the coefficients 
;
; Restrictions:	This version of the routine is written against IGRF-12, and is
;               valid between 1900 and 2020.  When future model versions are
;               released, this routine will need to be modified to ingest the
;               new version.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 21-Sep-2005, William Thompson, GSFC
;               Version 2, 29-Sep-2005, William Thompson, GSFC
;                       Changed FIND_WITH_DEF to CONCAT_DIR
;               Version 3, 25-Jan-2012, William Thompson, GSFC
;                       Use IGRF-11 instead of IGRF-10
;               Version 4, 15-Apr-2016, WTT, Use IGRF-12
;               Version 5, 26-Apr-2016, WTT, renamed from STEREO_IGRF_POLE
;
; Contact     :	WTHOMPSON
;-
;
pro get_sunspice_igrf_pole, date, theta, phi, errmsg=errmsg
;
on_error, 2
common get_sunspice_igrf_pole, years, g10coeff, g11coeff, h11coeff
;
;  Check the input parameters.
;
if n_params() ne 3 then begin
    message = 'Syntax: GET_SUNSPICE_IGRF_POLE, DATE, THETA, PHI'
    goto, handle_error
endif
;
;  If the first time this routine is called, read in the needed coefficients.
;
if n_elements(years) eq 0 then begin
    file = concat_dir(getenv('SSW_SUNSPICE_GEN'), 'igrf12coeffs.txt')
    if not file_exist(file) then begin
        message = 'File ' + file + ' not found'
        goto, handle_error
    endif
    openr, unit, file, /get_lun
;
;  Start by reading in the years.
;
    line = 'String'
    for i=0,3 do readf, unit, line
    words = str_sep(strcompress(strmid(line,2)), ' ')
;;  n0 = where(strupcase(words) eq 'SV') - 1
    n0 = n_elements(words) - 2
    years = float(words[3:n0])
;
;  Read in the first three coefficients.
;
    readf, unit, line
    words = str_sep(strcompress(strmid(line,2)), ' ')
    g10coeff = double(words[3:n0])
;
    readf, unit, line
    words = str_sep(strcompress(strmid(line,2)), ' ')
    g11coeff = double(words[3:n0])
;
    readf, unit, line
    words = str_sep(strcompress(strmid(line,2)), ' ')
    h11coeff = double(words[3:n0])
endif
;
;  Convert the date into UTC external format, and extract the year.
;
message = ''
utc = anytim2utc(date, /external, errmsg=message)
if message ne '' then goto, handle_error
year = utc.year
;
;  Form the date representing the beginning of the year.
;
year_begin = utc
year_begin[*].month = 1
year_begin[*].day = 1
year_begin[*].hour = 0
year_begin[*].minute = 0
year_begin[*].second = 0
year_begin[*].millisecond = 0
;
;  Form the date representing the end of the year (i.e. the beginning of the
;  next year).
;
year_end = year_begin
year_end[*].year = year + 1
;
;  Convert the three to TAI seconds, and calculate the fractional year.
;
year_begin = utc2tai(year_begin)
year_end = utc2tai(year_end)
year = year + (utc2tai(utc) - year_begin)/ (year_end - year_begin)
;
;  Interpolate the coefficients to the fractional year.
;
g10 = interpol(g10coeff, years, year)
g11 = interpol(g11coeff, years, year)
h11 = interpol(h11coeff, years, year)
;
;  Calculate the magnetic latitude and longitude from the coefficients.
;
c11 = sqrt(g11^2 + h11^2)
theta = !dpi/2.d0 - atan(-c11/g10)
phi = atan(-h11/c11, -g11/c11)
return
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message else $
  errmsg = 'GET_SUNSPICE_IGRF_POLE: ' + message
;
end
