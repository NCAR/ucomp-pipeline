FUNCTION udate2ex, timestr, cmd=cmd
;
;+
;NAME:
;	udate2ex
;PURPOSE:
;	Converts time string from UNIX command "date"
;	to the 7-element time representation
;INPUT:
;	timestr - string with date in GMT (UT) format
;		"Wed Jun  2 09:48:24 GMT 1993"
;OPTIONAL KEYWORD INPUT:
;	cmd	- The Unix date command to spawn (examples: date,
;		  date -u, ...)
;OUTPUT:
;	returns 7-element integer array (hh, mm, ss, msec, dd, mm, yy)
; History:
;	Written June 2, 1993  Barry LaBonte
;	Renamed from GTM2EX to UDATE2EX
;-
;
if (keyword_set(cmd)) then spawn, cmd, timestr
if (n_elements(timestr) eq 0) then spawn, 'date -u', timestr

montharr = [ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ]

len = STRLEN(timestr)
len = len(0)
timarr = INTARR(7)
pcolon = STRPOS( timestr, ':' )
pcolon = pcolon(0)

; Hour
timarr(0) = FIX( STRMID( timestr, pcolon-2, 2) )

; Minute
timarr(1) = FIX( STRMID( timestr, pcolon+1, 2) )

 ; Second
timarr(2) = FIX( STRMID( timestr, pcolon+4, 2) )

; Day
timarr(4) = FIX( STRMID( timestr, pcolon-5, 2) )

; Month
mon = STRMID( timestr, pcolon-9, 3)
monnum = WHERE( montharr EQ mon(0) )
timarr(5) = FIX( monnum(0)) + 1

; Year
timarr(6) = FIX( STRMID( timestr, len-2, 2))

RETURN, timarr
END

