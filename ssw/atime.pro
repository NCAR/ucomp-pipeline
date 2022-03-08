FUNCTION ATIME,UT,PUBLICAT=PUB ;ut to 'YY/MM/DD, HHMM:SS.XXX'
on_error,2
!quiet=1
;+
; NAME: 
;	ATIME
; PURPOSE:
;	Convert argument UT to string of format YY/MM/DD, HHMM:SS.XXX or
;	YY/MM/DD, HH:MM:SS.XXX, if PUB is set
; CALLING SEQUENCE:
;	RESULT = ATIME(UT,/PUB)
; INPUTS:
;	UT - Time to convert to string, in double precision seconds since
;	     79/1/1, 0000:00.000
; OPTIONAL INPUTS:
;	/PUB - Resulting string will have a colon (:) between hours and minutes
; MODIFICATION HISTORY:
;	Written by Richard Schwartz for IDL Version 2, Feb. 1991
;-
;
ymd2sec,days_month=days_month,iutyears=iutyears,/alt ;initialize arrays
;	days_month- # of days elapsed in year preceding the first of 12 mnths
;	iutyears  - # of days elapsed since 79/1/1 to start of each year
;		    from 79/1/1 to 99/1/1
;for days up to the first of the month and days up to the first of the year
days=(ut+4.d-04)/86400.d0 
;!!!!!!!!!!!!!N.B. 4.d-04 sec is round up error correction for conversion
;!!!!!!!!!!!!!     accuracy of .001 seconds !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;;if (days ge 0) and (days lt 7670.) then begin ;time is within range	;MDM removed 1999 year limitation
if (days ge 0) then begin ;time is within range
w1=where(fix(days)-iutyears ge 0) ;find the year starting from 1979
i1=w1(!err-1)
yr = i1+79			;MDM
yy=strtrim(i1+79,2)
day_in_year=days-iutyears(i1)
;ADJUST FOR LEAP YEARS; index 1,5,9,... are in leapyears
if (i1 mod 4 eq 1) and (day_in_year ge 59) then $
	days_month(2:*)=days_month(2:*)+1
w2=where( (fix(day_in_year)- days_month) ge 0)
i2=w2(!err-1)
mon = i2+101 mod 100			;MDM
mm=strmid(string(i2+101,'(i3)'),1,2) ; 01 through 12
resid=day_in_year-days_month(i2) ;residual from first of the month
dom=fix(resid) +101 ;day of month plus 100
date = dom mod 100			;MDM
;EXTRACT HOURS, MINUTES, AND SECONDS
h=(resid-fix(resid))*24.d0
m= fix((h*60) mod 60)
s= (h*3600) mod 3600 -m*60
;
tarr = [fix(h), fix(m), fix(s), fix(s*1000-fix(s)*1000.), date, mon, yr]		;MDM
tim_str = gt_time(tarr, /string, /msec)						;MDM
day_str = gt_day(tarr, /string)							;MDM

HHMM=strmid(string(100*fix(h)+fix(m)+10000,'(i5)'),1,4)
SS=strmid(string( s+100,'(f8.3)'),2,6)
dd=strmid(string(dom,'(i3)'),1,2) ;01 through 28,...31
; ans=YY+'/'+MM+'/'+DD+', '+HHMM+':'+SS
ans = day_str + ' ' + tim_str							;MDM
;; IF KEYWORD_SET(PUB) THEN ans=strmid(ans,0,12)+':'+strmid(ans,12,9)		;MDM
endif else begin ;INPUT UT IS OUT OF RANGE
	if days lt 0 then ans='< 79/01/01, 00:00:00.000
	if days ge 7670. then ans='> 99/12/31, 24:00:00.000
endelse
return,ans
END

