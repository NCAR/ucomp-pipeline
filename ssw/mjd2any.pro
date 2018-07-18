;+
;Project:
;       SPEX
;NAME:
;   MJD2ANY
;
;PURPOSE:
;   This function converts modified Julian days (MJD) to any of the anytim formats

; MJD = JD - 2400000.5
; JD is Julian Date
;CATEGORY:
;       UTPLOT, TIME, BATSE
;
;
;CALLING SEQUENCE:
;       time = mjd2any( item, /yoh)

;INPUT:
;       Item    - The input time in Modified Julian Day either as a numerical input or the
;     MJD structure available from anytim.pro
;                 Form can be scalar or vector integer, long, float, double
;OUTPUT:
;   The function returns the time in seconds from 1-jan-1979, ANYTIM
;   format or all anytim formats
;
;CALLS:
;   DATATYPE, ANYTIM
;KEYWORDS:
;   JULIAN - If set, input is in Julian days.
;   OUTPUT:
;     See anytim arguments
;       ERROR   - set if there is an error in time conversion
;
;RESTRICTIONS:
;   limited to output strings covered by ATIME.pro
;
;HISTORY:
;   9-feb-2004, ras
;
;MODIFIED:
;
;-
;
function mjd2any, mjd,  _extra=_extra, julian=julian, error=error

error = 0
dtype = size(/tname, mjd[0])

if dtype eq 'STRUCT' then if chktag( mjd,'MJD') then $
    return, anytim( mjd, _extra=_extra, error=error)

if dtype ne 'DOUBLE'  and  dtype ne 'FLOAT'  and dtype ne 'LONG'  and dtype ne 'INT' $
    then begin
       error=1
       print, 'Error in input format, type = ', dtype
       print, 'Argument to MJD2ANY must be numerical or a structure with tags TIME and MJD.'
       return, mjd
    endif

offset = keyword_set(julian) ?  2400000.5 + 43874.d0 : 43874.d0
ut =anytim(_extra=_extra, (mjd - offset) * 86400.,error=error)
return, ut
end
