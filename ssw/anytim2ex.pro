function anytim2ex, item, qstop=qstop, mdy=mdy
;
;+
;NAME:
;	anytim2ex
;PURPOSE:
;       Given a time in the form of a (1) structure, (2) 7-element time
;       representation, or (3) a string representation, or (4) an array
;       2xN where the first dimension holds (MSOD, DS79)
;	convert to the 7-element time representation (hh,mm,ss,msec,dd,mm,yy)
;CALLING SEQUENCE:
;	xx = anytim2ex(roadmap)
;	xx = anytim2ex('12:33 5-Nov-91')
;	xx = anytim2ex([0, 4000])
;INPUT:
;	tim_in	- The input time
;		  Form can be (1) structure with a .time and .day
;		  field, (2) the standard 7-element external representation
;		  or (3) a string of the format "hh:mm dd-mmm-yy"
;OPTIONAL KEYWORD INPUT:
;	mdy	- If set, use the MM/DD/YY order for converting the string date
;HISTORY:
;	Written 15-Nov-91 by M.Morrison
;	 5-Jan-93 (MDM) - Added /MDY option for TIMSTR2EX
;	11-Jan-93 (MDM) - Updated document header
;-
;
siz = size(item)
typ = siz( siz(0)+1 )
if (typ eq 8) then begin
    int2ex, gt_time(item), gt_day(item), out
end else if (typ eq 7) then begin
    out = timstr2ex(item, mdy=mdy)
end else begin
    if ((siz(0) eq 0) or (siz(0) gt 2)) then begin
	print, 'ANYTIM2EX: Need to be an array 2xN or 7xN (N can be zero)
	print, 'for either [msod, ds79] or 7-element array'
	return, 0
    end
    nx = siz(1)
    if (nx eq 7) then begin
	out = item
    end else begin
	int2ex, item(0,*), item(1,*), out
    end
end
;
return, out 
end
