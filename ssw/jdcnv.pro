PRO JDCNV,YR,MN,DAY,HR,JULIAN
;+
; NAME:
;       JDCNV
; PURPOSE:
;       Converts Gregorian dates to Julian days   
; CALLING SEQUENCE:
;       JDCNV,YR,MN,DAY,HR,JULIAN
; INPUTS:
;       YR = Year (integer)  
;       MN = Month (integer 1-12)
;       DAY = Day  (integer 1-31) 
;       HR  = Hours and fractions of hours of universal time (U.T.)
; OUTPUTS:
;       JULIAN = Julian date (double precision) 
; EXAMPLE:
;       To find the Julian Date at 1978 January 1, 0h (U.T.)
;       JDCNV,1978,1,1,0.,JULIAN
;       will give JULIAN = 2443509.5
; NOTES:
;       (1) JDCNV will accept vector arguments 
;       (2) JULDATE is an alternate procedure to perform the same function
; REVISON HISTORY:
;       Converted to IDL from Don Yeomans Comet Ephemeris Generator,
;       B. Pfarr, STX, 6/15/88
;-
if n_params(0) lt 4 then begin
	print,string(7B),'CALLING SEQUENCE: JDCNV,YR,MN,DAY,HR,JULIAN
        return
endif
yr = long(yr) & mn = long(mn) &  day = long(day)	;Make sure integral
L = (mn-14)/12		;In leap years, -1 for Jan, Feb, else 0
julian = day - 32075l + 1461l*(yr+4800l+L)/4 + $
         367l*(mn - 2-L*12)/12 - 3*((yr+4900l+L)/100)/4
julian = double(julian) + (HR/24.0D) - 0.5D
return
end
