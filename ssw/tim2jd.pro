
;+
; NAME:
;       TIM2JD
; PURPOSE:
;       Compute Julian day number from item.
; CATEGORY:
;	Time
; CALLING SEQUENCE:
;       jd = tim2jd(item)
; INPUTS:
;	Item - all time formats acceptable to ANYTIM().
; KEYWORD PARAMETERS:
;	HELP - does nothing.  Only for legacy.
; OUTPUTS:
;       jd = Julian Day number (like 2447000).  
; COMMON BLOCKS:
; NOTES:
;	y2k compliant with version 3.
; MODIFICATION HISTORY:
;       R. Sterner,  23 June, 1985 --- converted from FORTRAN.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 18 Sep, 1989 --- converted to SUN
;	Version 3.
;	richard.schwartz@gsfc.nasa.gov, 21-oct-1998, made y2k compliant using
;	anytim2jd in SSW distribution. All that remains is the name and arguments.
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
 
function tim2jd, item, help=help

out  = anytim2jd(anytim(/utc_int, item))

return, out.int + out.frac
 
end
