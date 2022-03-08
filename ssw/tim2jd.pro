
;-------------------------------------------------------------
;+
; NAME:
;       TIM2JD
; PURPOSE:
;       Compute Julian day number from item.
; CATEGORY:
; CALLING SEQUENCE:
;       jd = tim2jd(item)
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       jd = Julian Day number (like 2447000).   out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  23 June, 1985 --- converted from FORTRAN.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 18 Sep, 1989 --- converted to SUN
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
function tim2jd, item, help=help

time_ex = anytim2ex(item) 
msec = double(gt_time(anytim2ints(item)))

y = long(time_ex(6,*)) + 1900
m = long(time_ex(5,*))
d = long(time_ex(4,*))
jd = 367*y-7*(y+(m+9)/12)/4-3*((y+(m-9)/7)/100+1)/4 $
     +275*m/9+d+1721029
jd = jd - 0.5d0 + msec/86400000d	; Dunno why .5 days is subtracted
 
return, reform(jd)
end

