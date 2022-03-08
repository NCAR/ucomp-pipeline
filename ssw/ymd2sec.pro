PRO YMD2SEC,YMD=ymd,SEC=sec,DAYS_MONTHS=days_month,IUTYEARS=iutyears,ALT=ALT,$
		error=error 
on_error,2
!quiet=1
;+
; NAME: YMD2SEC
; PURPOSE: Convert YY/MM/DD string to sec.  Or if YMD and SEC parameters
;	aren't passed, to return arrays containing first of month and 
;	first of year relative to start of year and 79/1/1 respectively
; CALLING SEQUENCE: 
;	YMD2ED,YMD=YMD,SEC=SEC,DAYS_MONTH=DAYS_MONTH,IUTYEARS=IUTYEARS,
;		ALT=ALT,ERROR=ERROR
; INPUT PARAMETERS:
;	YMD -	ASCII string YY/MM/DD
;	ALT -	If set, then just return DAYS_MONTH and IUTYEARS arrays
; OUTPUT PARAMETERS:
;	SEC -	Result. Number of seconds since 79/1/1,0000 corresponding to
;		beginning of day specified in YMD.
;	DAYS_MONTH - Array containing first of month relative to start of year
;		in double precision seconds.
;	IUTYEARS - Array containing first of year relative to 79/1/1 in double
;		precision seconds for 21 years starting at 80/1/1.
;	ERROR -	=0/1. If set to 1, indicates error in YY/MM/DD format.
; MODIFICATION HISTORY:
;	Written by Richard Schwartz, Feb. 1991
;	27-May-93 (MDM) - Modification to work past the year 2000
;-
error=0
days_month=intarr(12)+31
days_month(1)=28
i30=[3,5,8,10]
days_month(i30)=intarr(4)+30
for i=1,11 do days_month(i)=days_month(i-1)+days_month(i)
days_month=[0,days_month(0:10)]
;utyears=86400.d0*365.25*findgen(21)
utyears=86400.d0*365.25*findgen(51)	;MDM changed from 21 to 51 years 27-May-93
iutyears=long(utyears/86400.+.5)
IF KEYWORD_SET(ALT) THEN RETURN
;PARSE THE STRING
test=ymd
b1=strpos(test,'/')
b2=strpos(test,'/',b1+1)
y=fix(strmid(test,0,b1))
m=fix(strmid(test,b1+1,b2-b1-1))
d=fix(strmid(test,b2+1,2))
if (y gt 99) or (y lt 79) then begin
	print,'Error, year must be 79-99.
	error=1
endif
if (m gt 12) or (m lt 1) then begin
	print,'Error, month must be 1-12.
	error=1
endif
if (d gt 31) or (d lt 1) then begin
	print,'Error, day is out of range.
	error=1
endif
if error then return
sec=(iutyears(y-79)+days_month(m-1)+(d-1))*86400.d0
if (y mod 4 eq 0) and (m ge 3) then sec=sec+86400. ;ALLOW LEAPYEAR
return
end


