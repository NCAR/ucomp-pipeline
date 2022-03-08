function fmt_tim, tim_in, day_str, time_str, msec=msec, nolead0=nolead0, fits=fits
;
;+
;NAME:
;	fmt_tim
;PURPOSE:
;	Given a time (or array of times) return the formatted
;	date/time string.
;CALLING SEQUENCE:
;	print, fmt_tim(roadmap)
;	print, fmt_tim(index(i).gen)
;	tim = fmt_tim(index, day_str, time_str)
;INPUT:
;	tim_in - Can be a structure with the .TIME and .DAY
;		 fields
;			(OR)
;		 The "standard" 7 element external representation
;		 of time (HH,MM,SS,MSEC,DD,MM,YY)
;OPTIONAL INPUT:
;       msec    - If present, also print the millisec in the formatted
;                 output.
;       nolead0 - If present, do not include a leading "0" on the hour string
;                 for hours less than 10. (ie: return 9:00:00 instead of 09:00:00)
;	fits	- If present, then use the FITS slash format of the type DD/MM/YY
;OUTPUT:
;	Returns the whole date/time string formatted in the
;	form like: 12-OCT-91  23:25:10
;
;OPTIONAL OUTPUT:
;	day_str - just the date part of the string
;	time_str- just the time part of the string
;HISTORY:
;	written Fall '91 by M.Morrison
;	13-Nov-91 (MDM) - Added capability to pass the index
;			  and have the ".gen" nested structure accessed
;	13-Nov-91 (MDM) - Removed the "guts" and put them inside
;			  "gt_time" and "gt_day"
;       15-Nov-91 (MDM) - Added "msec" and "nolead0" options
;	 4-Aug-95 (MDM) - Added /FITS keyword
;-
;
day_str = gt_day(tim_in, /str, fits=fits)
time_str = gt_time(tim_in, /str, msec=msec, nolead0=nolead0)
;
return, day_str + '  ' + time_str
end	
