;+
; Project     :	Multimission
;
; Name        :	CONVERT_SUNSPICE_GSE2SM
;
; Purpose     :	Converts GSE to SM coordinates.
;
; Category    :	SUNSPICE, Orbit
;
; Explanation :	This routine converts from geocentric solar ecliptic (GSE) to
;               solar magnetic (SM) coordinates.  Normally called from
;               GET_SUNSPICE_COORD.
;
; Syntax      :	CONVERT_SUNSPICE_GSE2SM, DATE, COORD
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
;               ITRF93  = If set, then use the high precision Earth PCK files
;                         loaded by LOAD_SUNSPICE_EARTH instead of the default
;                         IAU_EARTH frame.
;
;               ERRMSG  = If defined and passed, then any error messages will
;                         be returned to the user in this parameter rather than
;                         depending on the MESSAGE routine in IDL.  If no
;                         errors are encountered, then a null string is
;                         returned.  In order to use this feature, ERRMSG must
;                         be defined first, e.g.
;
;                               ERRMSG = ''
;                               State = CONVERT_SUNSPICE_GSE2SM( ERRMSG=ERRMSG, ... )
;                               IF ERRMSG NE '' THEN ...
;
; Calls       :	GET_SUNSPICE_IGRF_POLE, CSPICE_STR2ET, CSPICE_PXFORM
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
;               Version 4, 29-Sep-2005, William Thompson, GSFC
;                       Handle both position and velocity
;               Version 5, 05-Oct-2005, William Thompson, GSFC
;                       Fixed errors in calculation
;               Version 6, 18-Oct-2005, William Thompson, GSFC
;                       Fixed bug with inverse for 6-vectors
;                       Fixed bug with CMAT treatment
;               Version 7, 29-Jun-2010, WTT, changed loop to long
;               Version 8, 26-Apr-2016, WTT, renamed from STEREO_GSE2SM
;               Version 9, 29-Jun-2016, WTT, added ITRF93 keyword
;
; Contact     :	WTHOMPSON
;-
;
pro convert_sunspice_gse2sm, date, coord, cmat=cmat, inverse=inverse, $
                           itrf93=itrf93, errmsg=errmsg
;
on_error, 2
if n_params() ne 2 then begin
    message = 'Syntax:  Result = CONVERT_SUNSPICE_GSE2SM( DATE, COORD )'
    goto, handle_error
endif
;
sz = size(coord)
n_vec = sz[1]
if (n_vec ne 3) and (n_vec ne 6) then begin
    message = 'First dimension of COORD must be either 3 or 6'
    goto, handle_error
endif
;
;  Get the magnetic pole position as a function of date.
;
message = ''
get_sunspice_igrf_pole, date, theta, phi, errmsg=message
if message ne '' then goto, handle_error
;
;  Determine whether or not the ITRF93 kernels for Earth should be loaded.
;
if keyword_set(itrf93) then begin
    message = ''
    load_sunspice_earth, errmsg=message, _extra=_extra
    if message ne '' then goto, handle_error
    earth_frame = 'ITRF93'
end else earth_frame = 'IAU_EARTH'
;
;  Convert the date/time to ephemeris time, and calculate the transformation
;  matrices from geographic to GSE coordinates.
;
message = ''
utc = anytim2utc(date, /ccsds, errmsg=message, _extra=_extra)
if message ne '' then goto, handle_error
cspice_str2et, utc, et
cspice_pxform, earth_frame, 'GSE', et, xform
if n_vec eq 6 then cspice_pxform, earth_frame, 'GSE', et+1, xform2
;
;  Step through each date.
;
matrix = dblarr(n_vec,n_vec)
for i = 0L,n_elements(date)-1 do begin
;
;  Determine the position of the dipole axis in GSE coordinates.
;
    sin_theta = sin(theta[i])
    cos_theta = cos(theta[i])
    sin_phi   = sin(phi[i])
    cos_phi   = cos(phi[i])
    dipole = [cos_theta*cos_phi, cos_theta*sin_phi, sin_theta]
    if n_vec eq 6 then dipole2 = xform2[*,*,i] ## dipole
    dipole = xform[*,*,i] ## dipole
;
;  Use the dipole axis to calculate the conversion matrix.
;
    psi = atan(dipole[1] / dipole[2])
    sin_psi = sin(psi)
    cos_psi = cos(psi)
    mu = -atan(dipole[0] / sqrt(dipole[1]^2 + dipole[2]^2))
    sin_mu = sin(mu)
    cos_mu = cos(mu)
    matrix[0,0] = cos_mu
    matrix[0,1] = sin_mu * sin_psi
    matrix[0,2] = sin_mu * cos_psi
    matrix[1,0] = 0
    matrix[1,1] = cos_psi
    matrix[1,2] = -sin_psi
    matrix[2,0] = -sin_mu
    matrix[2,1] = cos_mu * sin_psi
    matrix[2,2] = cos_mu * cos_psi
    if n_vec eq 6 then begin
        matrix[3:5,3:5] = matrix[0:2,0:2]
        psi = atan(dipole2[1] / dipole2[2])
        sin_psi = sin(psi)
        cos_psi = cos(psi)
        mu = -atan(dipole2[0] / sqrt(dipole2[1]^2 + dipole2[2]^2))
        sin_mu = sin(mu)
        cos_mu = cos(mu)
        matrix[3,0] = cos_mu           - matrix[0,0]
        matrix[3,1] = sin_mu * sin_psi - matrix[0,1]
        matrix[3,2] = sin_mu * cos_psi - matrix[0,2]
        matrix[4,0] = 0
        matrix[4,1] = cos_psi          - matrix[1,1]
        matrix[4,2] = -sin_psi         - matrix[1,2]
        matrix[5,0] = -sin_mu          - matrix[2,0]
        matrix[5,1] = cos_mu * sin_psi - matrix[2,1]
        matrix[5,2] = cos_mu * cos_psi - matrix[2,2]
    endif
;
;  If /INVERT was set, then invert the matrix.  For 3x3 matrices, the
;  transpose is the inverse.
;
    if keyword_set(inverse) then begin
        if n_vec eq 6 then matrix = invert(matrix) else $
          matrix = transpose(matrix)
    endif
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
  errmsg = 'CONVERT_SUNSPICE_GSE2SM: ' + message
;
end
