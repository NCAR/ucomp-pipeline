function tim2dset, struct, tim_in, qstop=qstop, qdebug=qdebug, delta_sec=delta_sec, offset=offset
;
;+
;NAME:
;	tim2dset
;PURPOSE:
;	Given a structure (roadmap or index), find the dataset with
;	the time closest to an input time.
;CALLING SEQUENCE:
;	xx = tim2dset(roadmap, tarr)
;	xx = tim2dset(roadmap, '12:33 5-Nov-91',delta_sec=delta_sec)
;	print, tim2set(roadmap)
;INPUT:
;	struct	- The roadmap or index structure to search
;	tim_in	- The reference time to search the dataset for.
;		  Form can be (1) structure with a .time and .day
;		  field, (2) the standard 7-element external representation
;		  or (3) a string of the format "hh:mm dd-mmm-yy"
;		- If no input is passed, the user is prompted for the
;		  time to use
;OPTIONAL OUTPUT KEWORDS:
;	delta_sec - Absolute value of the time difference in secs.
;	offset	- The time difference in seconds
;HISTORY:
;	Written Oct-91 by M.Morrison
;	20-apr-92, J.R. Lemen, Speeded up the alogorithm.
;	2-May-92 (MDM) Removed call to make_str - hardwired
;			the structure name
;	20-may-92, JRL, Added the delta_sec keyword
;	 9-Jun-92, MDM, Removed code and used ANYTIM2INTS
;	27-Jul-92, MDM, Return a scalar if there is only one element
;	 9-Mar-93, MDM, Made the FOR loop an integer*4 value
;	20-Jul-93, MDM, Added OFFSET option
;	11-Jan-94, MDM, Updated document header
;-
;
if (n_elements(tim_in) eq 0) then begin
    int2ex, gt_time(struct(0)), gt_day(struct(0)), tim_in
    input, 'Enter year   ', dummy, tim_in(6)	& tim_in(6) = dummy
    input, 'Enter month  ', dummy, tim_in(5)	& tim_in(5) = dummy
    input, 'Enter date   ', dummy, tim_in(4)	& tim_in(4) = dummy
    input, 'Enter hour   ', dummy, tim_in(0)	& tim_in(0) = dummy
    input, 'Enter minute ', dummy, tim_in(1)	& tim_in(1) = dummy
    input, 'Enter second ', dummy, tim_in(2)	& tim_in(2) = dummy
end
;
daytim = anytim2ints(tim_in)
n = n_elements(daytim)
;
dset = lonarr(n)

struct_time = int2secarr(struct)
comp_time   = int2secarr(daytim,struct(0))
delta_sec = lonarr(n)
offset = fltarr(n)
;
for i=0L,n-1 do begin
    dt = struct_time - comp_time(i)
    delta_sec(i) = min(abs(dt), xx)
    dset(i)	 = xx
    offset(i)    = dt(xx)
;    delta_sec(i) = min(abs(struct_time-comp_time(i)), xx)
;    dset(i)	 = xx
;    if (keyword_set(qdebug)) then if ((i mod 100) eq 0) then print,i
endfor
;
if (n_elements(dset) eq 1) then dset=dset(0)	;turn it into a scalar
return, dset
end

