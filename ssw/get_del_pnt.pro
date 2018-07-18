function get_del_pnt, times, ref, x=x, y=y, z=z, qstop=qstop
;
;+
;NAME:
;	get_del_pnt
;PURPOSE:
;	Given a set of input times, find the offset in pointing
;	due to S/C pointing changes relative to a reference.
;SAMPLE CALLING SEQUENCE:
;	offset = get_del_pnt(index)
;INPUT:
;	times	- A set of times in an of the 3 standard formats
;OPTIONAL INPUT:
;	ref	- The reference time to use for finding the offsets
;		  relative to.  If not passed, it will use the first
;		  time in the input array.
;OUTPUT:
;	returns a vector 3xN of offsets in arcseconds relative to the
;	reference time of the S/C commanded pointing changes.  
;		(0) = East/West with East negative
;		(1) = North/South with South negative
;		(2) = Roll (
;	It does not take into account the 1 arcminute drift in pointing 
;	generally seen over an orbit.  Changes in the pointing bias value 
;	are taken into account.
;HISTORY:
;	Written 30-Nov-92 by M.Morrison
;-
;
common blk_get_del_pnt, pnt_hist
;
if (n_elements(ref) eq 0) then ref = times(0)
;
if (n_elements(pnt_hist) eq 0) then begin
    print, 'GET_DEL_PNT: Reading Pointing History file'
    rd_pnt_hist, pnt0
    n = n_elements(pnt0)
    pnt_hist = replicate(pnt0(0), n*2)		;duplicate all entries and have the second copy of the entry be the
						;start time of the next entry minus one second.  This way linear interpolation
						;routines can be used to find the proper pointing value for any input times
    for i=0,n-1 do pnt_hist(i*2) = pnt0(i)
    for i=0,n-2 do begin
	pnt_temp = pnt0(i)
	tim_temp = anytim2ints(pnt0(i+1), off=-1)	;back up one second
	pnt_temp.time = tim_temp.time
	pnt_temp.day  = tim_temp.day
	pnt_hist(i*2+1) = pnt_temp
    end
    pnt_hist(n*2-1) = pnt0(n-1)
    pnt_hist(n*2-1).day = 7670				;have the last available pointing value be valid well into the future
end
;
n = n_elements(times)
out = fltarr(3,n)
;
x1 = int2secarr(pnt_hist, ref)
x2 = int2secarr(times, ref)

out_ref = fltarr(3)
for i=0,2 do out_ref(i) = interpol(pnt_hist.offset(i), x1, 0)
for i=0,2 do out(i,*) = interpol(pnt_hist.offset(i), x1, x2) - out_ref(i)
;
if (keyword_set(x)) then out = out(0,*)
if (keyword_set(y)) then out = out(1,*)
if (keyword_set(z)) then out = out(2,*)
;
if (keyword_set(qstop)) then stop
return, out
end
