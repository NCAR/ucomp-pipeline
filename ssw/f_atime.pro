function f_atime, yr, month, dom, h, m, s, tarr=tarr, pub=pub, yohkoh=yohkoh, $
	y2k=y2k
on_error,2
;+
; NAME: 
;	F_ATIME
; PURPOSE:
;	Changes time info from numbers into formatted strings
;       restricted to no more than 256 separate times.
;	For ATIME, put date information, Year, Month, Day, Hour, Minute, Sec
;	into ATIME format YY/MM/DD, HHMM:SS.XXX
;
; CALLING SEQUENCE:
;	RESULT = F_ATIME(yr, month, dom, h, m, s [,/pub,/yohkoh])
;	       = F_ATIME(tarr=tarr [,/pub,/yohkoh])
; INPUTS:
;	YR - Year
;	MONTH - 1 to 12
;	DOM - Day of Month
;	H - hour
;	M - minute
;	S - second
; OPTIONAL INPUTS:
;	TARR - 7xn array of time as integers, 
;              The "standard" Yohkoh 7 element external representation
;              of time (HH,MM,SS,MSEC,DD,MM,YY)
;	/PUB - Publication format = "YY/MM/DD, HH:MM:SS.XXX"
;       /Yohkoh
;	     - Yohkoh string format, e.g. '07-Mar-93 21:05:30.461'
;	/Y2K - If set, then the four digit year format is preserved.

; MODIFICATION HISTORY:
;	Written by Richard Schwartz for IDL Version 2, July 1992
;	Optional Yohkoh format, and tarr, April 1993
;	07-Feb-2002, William Thompson, added keyword Y2K
;	6-apr-2007, richard schwartz,
;		Added format keyword for string function, 
;-
;

if n_elements(tarr) eq 0 then begin
	num = n_elements(yr)
	vec = intarr(1,num)
	
	h= vec + fix(hrs)
	m= vec + fix((hrs-h)*60)
	s= vec + (hrs - h ) * 3600.0d0 - m*60.0d0
	msec = fix((s mod 1)*1000)
	s=  fix(s)

tarr = [ h,m,s,msec,vec+fix(dom),vec+fix(month),vec+fix(yr)]
endif

if keyword_set(yohkoh) then begin
	
	;truncate leading digits   1989 --> 89
       	if not keyword_set(y2k) then tarr(6,*) = tarr(6,*) mod 100 

	day_str = gt_day( tarr, /lower, /lead, /string, y2k=y2k)
	time_str= gt_time(tarr, /string, /msec)
	ans = day_str + ' ' + time_str

endif else begin
	temp = (tarr(6,*))(*)
	if keyword_set(y2k) then yy=string(temp,format='(i4.4)') else $
		yy = string(temp mod 100, format='(i2.2)')
	mm=strmid(string((tarr(5,*))(*)+100,format='(i3)'),1,2) ; 01 through 12
	HHMM=strmid(string(100*(tarr(0,*))(*)+(tarr(1,*))(*)+10000,format='(i5)'),1,4)
	SS=strmid(string( (tarr(2,*) + tarr(3,*)/1.d3)(*) + 100,format='(f8.3)'),2,6)
	dd=strmid(string((tarr(4,*))(*)+100,format='(i3)'),1,2) ;01 through 28,...31

	ans=YY+'/'+MM+'/'+DD+', '+HHMM+':'+SS

	if keyword_set(pub) then ans=strmid(ans,0,12)+':'+strmid(ans,12,9)
endelse

return, ans
end

