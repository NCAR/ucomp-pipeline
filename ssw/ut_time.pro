function ut_time, time_in, int=int, ex=ex, to_local=to_local
;
;+
;NAME:
;	ut_time
;PURPOSE:
;       Return UT time / convert input times between Local and UT time
;
;OPTIONAL INPUT:
;	time_in	- A time (or times) in the local time zone to be converted
;		  to UT.  Input can be any of the 3 standard input formats.
;                 OR - uttimes to be converted to local times (/TO_LOCAL kwrd) 
;
;OPTIONAL KEYWORD INPUT:
;	int	- If set, return the time in the internal structure format
;		  Default is in string format
;	ex	- If set, return the time in the 7-element external format
;		  Default is in string format
;
;Calling Examples:
;      utnow      = ut_time()		; current UT time
;      uttimes    = ut_time(localtimes)   ; local->ut
;      localtimes = ut_time(uttimes,/to_local)
;HISTORY:
;	Written 4-Jun-93 by M.Morrison
;	 9-Nov-93 (MDM) - Patch to work with SGI
;        4-apr-95 (SLF) - add TO_LOCAL keyword and function 
;	                  use /noshell with spawn
;	 7-Jun-95 (MDM) - Added eastern time zones
;			- Added check that time zone was recognized
;	
;-
;
if (n_elements(time_in) eq 0) then begin
   time_in = !stime
   if keyword_set(to_local) then return, fmt_tim(time_in) ;**** no one should
endif							  ; ever do this ****

;
off = 0
case strupcase(!version.os) of
    'VMS': begin
		tbeep, 3
		off = -9
		print, 'VMS SYSTEM: Assuming your time zone is JST.'
	    end
    'IRIX': begin
		spawn, 'date', r,/noshell
		if (strpos(r(0), 'PST') ne -1) then off = +8
		if (strpos(r(0), 'PDT') ne -1) then off = +7
		if (strpos(r(0), 'EST') ne -1) then off = +5
		if (strpos(r(0), 'EDT') ne -1) then off = +4
		if (strpos(r(0), 'GMT') ne -1) then off =  0.000001
		if (off eq 0) then begin
		    print, 'UT_TIME: Time zone not recognized
		    print, r(0)
		    print, 'Please send mail to "software@isass0" regarding this'
		end
	    end
    else: begin			;unix that allows the -u switch
                spawn, ['date'],r,/noshell
                spawn, ['date','-u'],r1,/noshell
                r=[r,r1]
		ltim = udate2ex(r(0))
		uttim = udate2ex(r(1))
		off = int2secarr(uttim, ltim)/60./60.
		sign = off/abs(off)
		off = fix(off+sign*.5)	;round off problem - FIX rounds towards 0
	   end
endcase
;
if keyword_set(to_local) then off= -(off)	;invert offset 

out = anytim2ints(time_in, off=off*60.*60.)
;
if (keyword_set(int)) then return, out
if (keyword_set(ex)) then return, anytim2ex(out)
return, fmt_tim(out)
;
end
