function anytim2ints, tim_in, offset=offset, qstop=qstop, mdy=mdy
;
;+
;NAME:
;	anytim2ints
;PURPOSE:
;	Given a time in the form of a (1) structure, (2) 7-element time
;	representation, or (3) a string representation, or (4) an array 
;	2xN where the first dimension holds (MSOD, DS79)
;	convert to the a simple structure with .TIME and .DAY
;CALLING SEQUENCE:
;	xx = anytim2ints(roadmap)
;	xx = anytim2ints('1-sep-91', off=findgen(1000)*86400)
;	xx = anytim2ints('12:33 5-Nov-91')
;	xx = anytim2ints([0, 4000])
;INPUT:
;	tim_in	- The input time
;		  Form can be (1) structure with a .time and .day
;		  field, (2) the standard 7-element external representation
;		  or (3) a string of the format "hh:mm dd-mmm-yy"
;OPTIONAL KEYWORD INPUT:
;	offset	- The input time can be offset by a scalar or vector number of
;		  seconds.  If "offset" is an array, it should be the same 
;		  length at tim_in
;HISTORY:
;	Written 30-May-92 by M.Morrison
;        5-Jan-93 (MDM) - Added /MDY option for TIMSTR2EX
;	12-May-93 (MDM) - Modified to allow TIM_IN to be a single time, and
;			  OFFSET to be an array
;	11-Jan-94 (MDM) - Updated document header
;-
;
;
siz = size(tim_in)
nx = siz(1)
ny = 1
if (siz(0) eq 2) then ny = siz(2)
typ = siz( siz(0)+1 )
case typ of
    7: n = n_elements(tim_in)
    8: n = n_elements(tim_in)
    else: n = ny
endcase
;
if ((n eq 1) and (n_elements(offset) gt n)) then n = n_elements(offset)		;added 13-May-93
;
daytim = {anytim2ints, time: long(0), day: fix(0)}
daytim = replicate(daytim, n)
;
if (typ eq 8) then begin
    time = gt_time(tim_in)
    day  = gt_day(tim_in)
end else if (typ eq 7) then begin
    tarr = timstr2ex(tim_in, mdy=mdy)
    ex2int, tarr, time, day
end else begin
    if (nx eq 7) then begin
	ex2int, tim_in, time, day
    end else begin
	time = reform(tim_in(0,*))
	day  = reform(tim_in(1,*))
    end
end
;
if (keyword_set(offset)) then begin
     time = time + offset*1000L		;offset is input in seconds
     if ((n gt 1) and (n_elements(day) eq 1)) then day = day + intarr(n)	;added 13-May-93
     check_time, time, day
end
;
if (n eq 1) then begin
    daytim.time = time(0)	;trouble inserting an array of one element into the structure!!?!?
    daytim.day = day(0)
end else begin
    daytim.time = time
    daytim.day = day
end
;
return, daytim
end
