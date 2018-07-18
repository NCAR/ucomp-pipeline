;+
; Project     :	Multimission
;
; Name        :	CONVERT_SUNSPICE_GEO2MAG
;
; Purpose     :	Converts geographic to geomagnetic coordinates.
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	This routine converts geographic (GEO) to geomagnetic (MAG)
;               coordinates.  Normally called from GET_SUNSPICE_COORD.
;
; Syntax      :	CONVERT_SUNSPICE_GEO2MAG, DATE, COORD
;
; Examples    :	See GET_SUNSPICE_COORD
;
; Inputs      :	DATE    = The date and time.  This can be input in any format
;                         accepted by ANYTIM2UTC, and can also be an array of
;                         values.
;
;               COORD   = The 3-value or 6-value (with velocity) coordinate
;                         vector.  Can also be a 3xN or 6xN array, where N is
;                         the number of elements of DATE.
;
;                         Alternatively, when used with the /CMAT keyword, this
;                         is a 3x3 (or 3x3xN) tranformation C-matrix array.
;                         This keyword is used within GET_SUNSPICE_CMAT.
;
; Opt. Inputs :	None.
;
; Outputs     :	COORD   = Returned as the converted coordinate array.
;
; Opt. Outputs:	None.
;
; Keywords    : CMAT    = If set, then the input is a C-matrix.
;
;               INVERSE = If set, then perform the inverse transform, from GSM
;                         to GSE coordinates.
;
;               ERRMSG  = If defined and passed, then any error messages will
;                         be returned to the user in this parameter rather than
;                         depending on the MESSAGE routine in IDL.  If no
;                         errors are encountered, then a null string is
;                         returned.  In order to use this feature, ERRMSG must
;                         be defined first, e.g.
;
;                               ERRMSG = ''
;                               State = CONVERT_SUNSPICE_GEO2MAG( ERRMSG=ERRMSG, ... )
;                               IF ERRMSG NE '' THEN ...
;
; Calls       :	GET_SUNSPICE_IGRF_POLE
;
; Common      :	None.
;
; Restrictions:	Because this routine is intended to be called from
;               GET_SUNSPICE_COORD, very little error checking is done on the
;               input parameters.
;
; Side effects:	None.
;
; Prev. Hist. :	None.
;
; History     :	Version 1, 21-Sep-2005, William Thompson, GSFC
;               Version 2, 22-Sep-2005, William Thompson, GSFC
;                       Added keyword CMAT
;               Version 3, 23-Sep-2005, William Thompson, GSFC
;                       Added keyword INVERSE, fixed bug with /CMAT
;               Version 4, 18-Oct-2005, William Thompson, GSFC
;                       Additional bug fix for /CMAT
;               Version 5, 29-Jun-2010, WTT, changed loop to long
;               Version 6, 26-Apr-2016, WTT, renamed from STEREO_GEO2MAG
;
; Contact     :	WTHOMPSON
;-
;
pro convert_sunspice_geo2mag, date, coord, cmat=cmat, inverse=inverse, $
                            errmsg=errmsg
;
on_error, 2
if n_params() ne 2 then begin
    message = 'Syntax:  Result = CONVERT_SUNSPICE_GEO2MAG( DATE, COORD )'
    goto, handle_error
endif
;
;  Get the magnetic pole position as a function of date.
;
message = ''
get_sunspice_igrf_pole, date, theta, phi, errmsg=message
if message ne '' then goto, handle_error
;
;  Determine whether we're talking about 3-element vectors, or 6-element
;  vectors.
;
n = (size(coord))[1]
matrix = dblarr(n,n)
;
;  Step through each date, form the conversion matrix, and perform the
;  conversion.
;
for i = 0L,n_elements(date)-1 do begin
    sin_theta = sin(theta[i])
    cos_theta = cos(theta[i])
    sin_phi   = sin(phi[i])
    cos_phi   = cos(phi[i])
    matrix[0,0] = sin_theta * cos_phi
    matrix[0,1] = sin_theta * sin_phi
    matrix[0,2] = -cos_theta
    matrix[1,0] = -sin_phi
    matrix[1,1] = cos_phi
    matrix[1,2] = 0
    matrix[2,0] = cos_theta * cos_phi
    matrix[2,1] = cos_theta * sin_phi
    matrix[2,2] = sin_theta
    if n eq 6 then matrix[3:5,3:5] = matrix[0:2,0:2]
;
;  If /INVERT was set, then transpose (invert) the matrix.
;
    if keyword_set(inverse) then matrix = transpose(matrix)
;
    if keyword_set(cmat) then coord[*,*,i] = matrix # coord[*,*,i] else $
      coord[*,i] = matrix # coord[*,i]
endfor
;
return
;
;  Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message else $
  errmsg = 'CONVERT_SUNSPICE_GEO2MAG: ' + message
;
end
