FUNCTION ATIME,UT, PUBLICAT=PUB, Yohkoh=Yohkoh, hxrbs=hxrbs, nopub=nopub,$
	date=date, time=time, error=error, y2k=y2k

on_error,2
;+
; NAME: 
;	ATIME
; PURPOSE:
;	Convert argument UT to string of format YY/MM/DD, HHMM:SS.XXX or
;	YY/MM/DD, HH:MM:SS.XXX, if PUB is set
; CALLING SEQUENCE:
;	RESULT = ATIME(UT[,/PUB,/yohkoh])
; INPUTS:
;	UT  - Time to convert to string, in any representation
;	      double precision seconds since 79/1/1, 0000:00.000
;	      7XN integer
;	      2XN longword [msod, ds79]
;             Structure with .time and .day
;	      See ANYTIM for allowed types
; OPTIONAL INPUTS:
;	/PUB - Resulting string will have a colon (:) between hours and minutes
;		using HXRBS format
;	/Yohkoh - Forces Yohkoh date format DD-mon-YY HH:MM:SS.MSC
;	/hxrbs  - Forces HXRBS date pub format yy/mm/dd, hh:mm:ss.xxx
;		  same effect as /pub
;	/nopub  - Forces HXRBS date format w 1 colon, yy/mm/dd, hhmm:ss.xxx
;	/date   - return only the calendar date component of the string, i.e. yy/mm/dd
;	/time   - return only the time portion of the string, i.e. hh:mm:ss.xxx
;	/y2k	- preserve 4-digit years
;	NB, these style booleans may be changed in the code and returned 
;	that way if you haven't used the /keyword syntax.
;
; MODIFICATION HISTORY:
;	Written by Richard Schwartz for IDL Version 2, Feb. 1991
;	Modified to vectors 7/9/92, RAS
;	" uses DAYCNV.PRO from IDL Astronomy Library
;	" uses f_atime.pro to format the output
;	" preserves dimensionality of input array, vectors, and scalars, 8/10/92
;	Yohkoh keyword/format, 30-apr-93, ras
;	Added more style control, Yohkoh/HXRBS, 3-Nov-93
;	29-Nov-93, Protect against OSF bug in total, ras
;	14-Dec-93 (MDM) - Uncommented ATIME_FORMAT line
;	5-jan-94, added time and date keywords, ras
;	3-mar-94, added error keyword
;       RAS 8-mar-94 - protect against strings of the form 14-Feb-93 24:00:00
;       15-May-98 (FZ)  - Changed loop variable i to long
;	07-Feb-2002, William Thompson, added keyword Y2K
;-
;

; This common contains atime_format

ans = ''
error = 0

@utstart_time_com
;COMMON UTSTART_TIME, PRINT_START_TIME, ATIME_FORMAT
;;checkvar, atime_format ,'YOHKOH'		;MDM uncommented out 14-Dec-93
atime_format = fcheck(atime_format,'YOHKOH')	;MDM replaced CHECKVAR with FCHECK

if (size(ut))(0) eq 0 then scalar = 1 else scalar=0
typ=datatype(ut)
if typ eq 'DOU' or typ eq 'FLO' or typ eq 'STR' then form = strmid(ut,0,0)
if typ eq 'STC' then form= strarr( n_elements(ut) ) ;simple dimensions only

;29-Nov, ras
;if typ eq 'LON' or typ eq 'INT' then form=strmid( 0*total(ut,1),0,0)
;changed to protect against OSF bug

if typ eq 'LON' or typ eq 'INT' then $
	if (size(ut))(0) eq 1 then form=strarr(1) else $
		form=strmid( 0*total(ut,1),0,0)
ex = anytim( ut, out='ex',error=error)  ;7xN integer representation of time
if error then goto, getout

ex = anytim(/ex, anytim(ex, /sec))                              ;RAS 8-mar-94

num = n_elements( ex(0,*) ) 

ans = strarr(num)

;set up keywords to control output
;Absolute default is HXRBS style
;If Yohkoh environment, then atime_format will be set to 'yohkoh'
;and the Yohkoh style string is the default, which can be overriden
;by the HXRBS keyword.  Likewise the YOHKOH keyword will force the YOHKOH
;style.
	if STRUPCASE( ATIME_FORMAT ) EQ 'YOHKOH' and not keyword_set(hxrbs) $
		then yohkoh=1
	if STRUPCASE( ATIME_FORMAT ) EQ 'HXRBS' and not keyword_set(yohkoh) $
		then yohkoh=0
	IF keyword_set(yohkoh) then yohkoh=1
	if keyword_set(hxrbs) then yohkoh=0
	if keyword_set(pub) then pub=1
	if keyword_set(nopub) then pub=0


;Strings must be broken into groups of 256 or less to use formatting
for i=0L,num-1,256 do begin
   i2 = (i+255)<(num-1)
   ans(i:i2) = $
	f_atime( yohkoh=yohkoh, pub=pub, tarr= ex(*,i:i2 ), y2k=y2k)
endfor

;IF KEYWORD_SET(PUB) THEN $
;	ans=strmid(ans,0,12)+':'+strmid(ans,12,9)

;return scalar or vector depending on ut
ans = form + ans
if scalar then ans=ans(0)
;
; Provide users with commonly desired substrings
; Date keyword supercedes time keyword
case 1 of
 keyword_set(date) and yohkoh: 			ans=strmid( ans, 0, 9) 
 keyword_set(date) and not yohkoh:		ans=strmid( ans, 0, 8)

 keyword_set(time) and (keyword_set(pub) or yohkoh): 		ans = strmid(ans, 10,12) 
 keyword_set(time) and not yohkoh and not keyword_set(pub): 	ans = strmid(ans, 10,11) 
 1:
endcase 

getout:
return,ans
END
