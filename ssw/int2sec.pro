function int2sec, time_arr
;						16-Oct-91
;+
;Name:
;	int2sec
;Purpose:
;	To convert the "standard" internal
;	representation array into a time series
;	vector in seconds.
;Input:
;	time_arr - A structure array with the
;		fields .TIME and .DAY
;			(OR)
;		A 2xN array with the MSOD variable first, and the DS79
;		variable second (see example).  It
;		is assumed that they are the same length
;			(OR)
;		A 7xN array which hold the 7-element external 
;		representation of time.
;Output:
;	returns a single array with the number 
;	of seconds past the reference value 1 assumed to be for 01-jan-1979.
;Examples:
;	d = int2secarr( roadmap )
;	d = int2secarr( [msod,ds79] )
;
;History:
;	Modified from int2secarr to treat 1-Jan-79 as epoch reference time
;	RAS, 93-6-7
;-
;
siz = size(time_arr)
nx = siz(1)
ny = 1
if (siz(0) eq 2) then ny = siz(2)
typ = siz(siz(0)+1)
case typ of
    8: begin
	day = gt_day(time_arr)
	time = gt_time(time_arr)
       end
    7: begin
	ex2int, time_arr, time, day ;only accepts 7XN variable
       end
    else: begin
	if (nx eq 2) then begin
	    time = time_arr(0,*)
	    day = time_arr(1,*)
	end else begin
	    ex2int, time_arr, time, day
	end
    end
end
;
;
out = (day-1)*86400.d0 + (time)/1000.d0
;
return, out
end

