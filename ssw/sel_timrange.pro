function sel_timrange, array, st_tim, en_tim, between=between, after=after, $
		st_before1st=st_before1st, en_afterlast=en_afterlast, qdebug=qdebug, $
		boolean=boolean
;
;
;+
;NAME:
;	sel_timrange
;PURPOSE:
;	Given a range of times (or a single time) and a time array, return the
;	subscripts of the times between the selected time range.  If /BOOLEAN,
;	then return a bytarr the length of the input marking where within range.
;SAMPLE CALLING SEQUENCE:
;	ss = sel_timrange(timarr, st_tarr, en_tarr)
;	ss = sel_timrange(timarr, st_tarr, en_tarr, /between)
;	ss = sel_timrange(roadmap, '1-nov-91 22:00', '1-nov-91 22:30')
;	ist = sel_timrange(neworb_p, st_tarr, st_before1st=st_before1st)
;	ien = sel_timrange(neworb_p, en_tarr, en_afterlast=en_afterlast, /after)
;INPUT:
;	timarr	- An array of times
;	st_tarr	- The specified start time
;OPTIONAL INPUT:
;	en_tarr	- The specified end time.  If it is not passed, then the
;		  start time is used (time range of 0 seconds)
;OPTIONAL KEYWORD INPUT:
;	between	- The default is to give the last entry before the start time.  
;		  This is because the input time is usually a pointer (or file name)
;		  with the time of the start of the orbit.  So the selection 
;		  desired is needs to back up one element in the timarr.  This
;		  is only done when the input start time does not exactly match the 
;		  "timarr" value.
;	after	- If set, get the first dataset after the input time range
;	boolean - If set, then return an array the same length as the input, and
;		  set all values within the range to 1.
;OPTIONAL KEYWORD OUTPUT:
;	st_before1st - If set, then the input start time is before the first time
;			in "timarr"
;	en_afterlast - If set, then the input end time is after the last time
;			in "timarr"
;HISTORY:
;	Written Oct-92 by M.Morrison
;	29-Oct-92 (MDM) - Corrected an error in "en_afterlast" determination
;	30-Oct-92 (MDM) - Added /AFTER which corrected for a problem
;	 		  with the RD_PNT logic
;-
;
;	s0  s1  s2  s3  s4  s5  s6  s7			BETWEEN		LAST_BEFORE	st_before1st	en_afterlast
;									(default)
;A)        S						-1		0		0		0
;B)	  S E						1		01		0		0
;C)    S						-1		-1		1		0
;D)                                        S		-1		7		0		1
;E)    S                                   E		01234567	01234567	1		1
;F)	      S               E				2345		12345		0		0
;	s0  s1  s2  s3  s4  s5  s6  s7
;
;/BETWEEN - give all datasets between "st_tim" and "en_tim" - see case A since -1 is returned for this
;/LAST_BEFORE - give last datasets before "st_tim" (DEFAULT)
;
n = n_elements(array)
st_tim0 = anytim2ints(st_tim)
if (n_elements(en_tim) eq 0) then en_tim0 = st_tim0 else en_tim0 = anytim2ints(en_tim)
;
st_before1st = (int2secarr(st_tim0, array(0)) lt 0)	;fixed 29-Oct-92
en_afterlast = (int2secarr(en_tim0, array(n-1)) gt 0)	;fixed 29-Oct-92
;
ss = where( (int2secarr(array, st_tim0) ge 0) and (int2secarr(array, en_tim0) le 0) )
out = ss
if (not keyword_set(between)) then begin
    nss = n_elements(ss)
    if (keyword_set(after)) then begin
	if (ss(0) eq -1) then begin	;check for input times falling between "array" times
	    ss = where(int2secarr(array, st_tim0) gt 0, count)
	    if (count ne 0) then out = ss(0)
	end else begin
	    if ((int2secarr(array(ss(nss-1)), en_tim0) ne 0) and (ss(nss-1) ne nss-1)) then out = [ss, ss(nss-1)+1]	;move forward one
	    ;Don't move forward if the match was identical
	end
    end else begin
	if (ss(0) eq -1) then begin	;check for input times falling between "array" times
	    ss = where(int2secarr(array, st_tim0) lt 0, count)
	    if (count ne 0) then out = ss(count-1)	;last one before start time
	end else begin
	    if ((int2secarr(array(ss(0)), st_tim0) ne 0) and (ss(0) ne 0)) then out = [ss(0)-1, ss]	;back up one value
	    ;Don't back up if the match was identical
	end
    end
end
;
if (keyword_set(boolean)) then begin
    save_out = out
    out = bytarr(n)
    if (save_out(0) ne -1) then out(save_out) = 1b
end
;
if (n_elements(out) eq 1) then out = out(0)	;turn into scalar
if (keyword_set(qdebug)) then stop
return, out
end
    
