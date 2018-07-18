;+
;Function :
;	Utime2str
;Use:
;	ut_str= utime2str( seconds [,utbase=utime('yy/mm/dd, hhmm:ss.xxx')] )
;
;Inputs:
;	Seconds - time in seconds from basetime in UTcommon or as --->
;	Utbase  -  Reference time in seconds from 79/1/1
;		   0 is accepted as a valid argument.
;Output:
;	Structure UT_STR with two tagnames
;		.DAY - Day from 79/1/1 (day=1), longword
;		.TIME- Msec from start of day, longword
;
;Purpose:
;	To facilitate passing times to Yohkoh software without using double
;	precision and to make it compatible with the Yohkoh UTPLOT package.
;
;	N.B.  Not all versions of IDL can sucessfully translate double
;	precision between DEC VMS and MIPS machines even in XDR
;	format.  Also, integers cannot be used for .DAY and Longword
;	for .TIME because it fails to be read properly.  Probably, an 
;	alignment problem, Unix likes variables on fullword boundaries.
;
;History:
;	RAS, 93/4/6
;	ras, 29-nov-93, fixed structure/scalar incompatibilty
;	ras, 11-jan-94, fixed problem with negative numbers
;	ras, 4-May-94, fixed round-off error in day calculation
;	ras, 28-oct-95, rewrite using floor function
;-
function utime2str, seconds, utbase=utbase


ut_str = {ut_str,day:0L, time:0L}
ut_str = replicate( ut_str, n_elements(seconds) )

if n_elements( utbase) eq 0 then $
		ut = seconds+ getutbase(0) else ut = seconds + utbase

;wneg = where( ut lt 0, nneg)		;ras 11-jan-94
	
;29-Nov-93, fix structure scalar incompatibility, if only 1 element must have scalar on rhs
if n_elements(ut_str) eq 1 then begin
	ut_str.day = ( floor( ut/86400.d0 ) + 1)(0)
	time= ( ut -(ut_str.day-1)*86400.d0 )(0)
endif else begin
	ut_str.day = floor( ut/86400.d0 ) + 1
	time= ut -(ut_str.day-1)*86400.d0 
endelse



ut_str.time = long( time*1000.+.5)                      ;ras 11-jan-94 

return, ut_str
end

