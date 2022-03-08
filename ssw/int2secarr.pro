function int2secarr, time_arr, time_ref
;+
;Name:
;	int2secarr
;Purpose:
;	To convert any time format into a time series vector in seconds.
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
;	time_ref - OPTIONAL, the reference time from
;		which to calculate the number of
;		seconds that have passed.  If it is
;		missing, time_arr(0) is used
;		(the first value in the array)
;		It is a structure with .TIME and .DAY
;			(OR)
;		A two element array with the first element
;		being the MSOD, and the second being DS79
;			(OR)
;               A 7xN array which hold the 7-element external
;               representation of time.
;Output:
;	returns a single array with the number 
;	of seconds past the reference value.
;Examples:
;	d = int2secarr( roadmap )
;	d = int2secarr( roadmap, roadmap(100) )
;	d = int2secarr( [msod,ds79] )
;
;History:
;	written 12-Oct-91 by M.Morrison
;	13-Nov-91 MDM - Changed to be able to work with nested structures
;			(called GT_TIME and GT_DAY)
;	16-Nov-91 MDM - Changed to also accept 7-element format (in
;			addition to 2-element and structure
;	 5-Mar-92 MDM - Changed to also accept a string convention of
;			time for the reference time.
;	20-Jul-93 MDM - Removed much code and replaced with calls to ANYTIM2INTS
;		      - Allowed two vectors of arrays to be passed
;        3-Jan-95 MDM - Changed to use DOUBLE instead of FLOAT
;                       because when using a reference time of
;                       1-Jan-79, the resolution/accuracy for dates
;                       in 1994 is less than 20 seconds!!
;-
;
time1 = anytim2ints(time_arr)
if (n_elements(time_ref) eq 0) then time2 = time1(0) else time2 = anytim2ints(time_ref)
;
n1 = n_elements(time1)
n2 = n_elements(time2)
;
if ((n2 ne 1) and (n1 ne n2)) then begin
    message, 'The reference time was not a single value, and the number', /info
    message, 'of elements does not match the input.  Using the first value only', /info
    time2 = time2(0)
end
;
out = (time1.day - time2.day)*86400.0D + (time1.time - time2.time) /1000.0D
;
return, out
end

