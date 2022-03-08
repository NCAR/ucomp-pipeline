
FUNCTION UTIME,UTSTRING0,ERROR=ERROR, DATE=DATE, TIME=TIME
;+
; NAME:
;	UTIME
; PURPOSE:
;	Function to return time in seconds from 79/1/1,0000 corresponding to
;       the ASCII time passed in the argument. 
;	N.B. Valid only from 1950-2050
; CATEGORY: 
; CALLING SEQUENCE: 
;	RESULT = UTIME(UTSTRING,/ERROR)
; INPUTS:
;	UTSTRING -	String containing time in form YY/MM/DD,HHMM:SS.XXX
;	    		Also accepts Yohkoh format time string:
;			DD-MON-YY HH:MM:SS.XXX
;			Will not accept HH:MM:SS.XXX DD-MON-YY
;	ERROR -		=0/1. If set to 1, there was an error in the ASCII
;			time string.
;	/date   - return only the calendar date component of the UTIME
;	/time   - return only the time day 

; OUTPUTS:
;	Double precision time in seconds since 79/1/1, 0000.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;       If just a time is passed (no date - detected by absence of slash
;       and comma in string), then just the time of day is converted to 
;	seconds relative to start of day and returned.  If date and time 
;	are passed, then day and time of day are converted to seconds and 
;	returned.  In other words, doesn't 'remember' last date used if 
;	no date is specified.  There is only rudimentary error checking,
;	strings like 82/02/30 will have the same value as 82/03/02.
; PROCEDURE:
;	Parses string into component parts, i.e. YY,MM,DD,HH,MM,SS.XXX,
;	converts the strings into double precision seconds using a gregorian
;	date to julian date algorithm.  Accepts vectors of strings as well
;	as scalar strings.
; MODIFICATION HISTORY:
; 	Written by Kim Tolbert 7/89
;	Modified for IDL Version 2 by Richard Schwartz Feb. 1991
;	Corrected RAS 91/05/02, error should be initialized to 0
;	Modified to accept vectors of dates by RAS, 92/07/07
;	Modified to accept vectors of any dimensionality by RAS, 92/08/10
;	Modified to automatically convert Yohkoh string format, ras, 01-May-93
;	Corrected 07-May-93 to again take whitespace in old date format, RAS	
;	added time and date keywords, ras, 5-jan-94
;	minor changes to error handling, ras, 7-jan-94
;-
on_error,2
error = 1  ; initialize to error

typ = datatype(utstring0) ;check for string
;if (size(utstring0(0)))(0) eq 0 then scalar = 1 else scalar = 0
if (size(utstring0))(0) eq 0 then scalar = 1 else scalar = 0
;if not a string, or a hxrbs string, make it a hxrbs string
if typ ne 'STR' or (where( strpos(utstring0,'-') ne -1))(0) ne -1 then $
	utstring = anytim( utstring0, out='hxrbs')  else utstring=utstring0

;if publication format then 'YY/MM/DD, HH:MM:SS.XXX
;Insert commas and eliminate blanks to simplify later parsing
;
;Here we have supported all blanks so we will remove all whitespace from
;strings which don't include dashes.  Yohkoh doesn't accept blanks in the
;datestring
  buff1 = utstring(*)
  wnodash = where(strpos( buff1, '-' ) eq -1,nnodash)
  if nnodash ge 1 then buff1(wnodash) = strcompress(buff1(wnodash),/remove)
;All whitespace removed from non dash strings, just as before

buff1 = byte( buff1 )

if n_elements(buff1) gt 1 then  begin ;must be more than 1 character in array
	wblnk = where( (buff1(1:*) eq 32b) and (buff1 ne 44b), nblnk)+1
	if nblnk ge 1 then buff1(wblnk) = 44b ;insert commas
endif

buff1 = string( buff1 ) ;convert back to a string array
buff1 = strupcase(strcompress(buff1,/remove)) ;eliminate whitespace
;

;Look for dashes indicating Yohkoh format, if found, convert to yy/mm/dd

dash = strpos( buff1, '-')
wdash = where( dash ne -1, ndash)

if ndash ge 1 then begin ;change yohkoh format into yy/mm/dd
	buff1 = byte(buff1(wdash)) ;
	buff1(where(buff1 eq 45b)) = byte('/') ;dashes to slashes
	wmonths = where( (buff1 ge 65b) and (buff1 le 90b),nmonths)
        if nmonths eq 0 then goto, errorlog   ; added by AKT 7/2/93
	months = string( reform(buff1(wmonths),3,nmonths/3))
	months = byte(strmid(strtrim(string(100+month_id(months)),2),1,2)+' ')
	buff1(wmonths) = months
	buff1 = strcompress( buff1, /rem)
endif

;default time is 79/01/01
n = n_elements(buff1)
yy = intarr(n) + 1979
mm = intarr(n) + 1
dd = intarr(n) + 1
hh = dblarr(n)
;PARSE THE YEAR, MONTH, AND DAY AND CONVERT THEM TO INT*2 
buff1 = byte(buff1)
;Look for publication format and clobber the second colon
wcolon = where( buff1 eq 58b, ncolon)
if ncolon gt 1 then begin; LOOK FOR COLONS WITHIN 3
	dcolon = wcolon(1:*) - wcolon
	w3 = where( dcolon le 3, n3)
	if n3 ge 1 then begin 
		buff1(wcolon(w3)) = 32b ;change it into a blank
		buff1 = byte(strcompress( string(buff1),/rem))
	endif
endif ;first PUBLICATION FORMAT Colon IS ELIMINATE

nl = n_elements( buff1(*,0) )

schar = string(buff1(0:3 <(nl-1),*))
slash = strpos(schar, '/')
colon = strpos(schar, ':')
period = strpos(schar, '.')

wslash = where( slash ne -1, nslash)
wcolon = where( colon ne -1, ncolon)
wperiod = where( period ne -1, nperiod)
wnone = where( (slash eq -1) and (colon eq -1) and (period eq -1) and $
		(dash eq -1), nnone)

;
buff2 = bytarr(20 > nl, n) ;quantities get placed in here

if nslash ge 1 then buff2(0:nl-1, wslash) = buff1(*, wslash)
if ncolon ge 1 then begin
	buff2(9:9+ (10 < (nl-1)),wcolon) = buff1(0:10 < (nl-1),wcolon)
	buff2(0:8,wcolon) = byte('79/01/01,')#replicate(1,1,ncolon)
endif
if nnone ge 1 then begin
	buff2(9:9+ (10 < (nl-1)),wnone) = buff1(0:10 < (nl-1),wnone)
	buff2(0:8,wnone) = byte('79/01/01,')#replicate(1,1,nnone)
endif

if nperiod ge 1 then begin
	buff2(14:14 + (5 < (nl-1)),wperiod) = buff1(0:5 < (nl-1),wperiod)
	buff2(0:13, wperiod) = byte('79/01/01,0000:')#replicate(1,1,nperiod)
endif

sbuff = string(buff2)
sleng  = strlen(sbuff)
colon = strpos( sbuff, ':') 
comma = strpos( sbuff, ',')
slash = strpos( sbuff, '/')

wcolon = where( colon gt comma, ncolon)
wcomma = where( comma gt slash and colon eq -1, ncomma)
wnone = where( (colon eq -1) and (comma eq -1), nnone) 

if ncolon ge 1 then begin ; COLON IS THE LAST NON-DIGIT CHARACTER
	wend = where( sleng(wcolon)-1 eq colon(wcolon), nend )
	if nend ge 1 then buff2(14:19,wcolon(wend)) = $
		byte('00.000')#replicate(1,1,nend)
endif

if ncomma ge 1 then begin ; COMMA IS THE LAST NON-DIGIT CHARACTER
	wmore = where( sleng(wcomma)-1 gt comma(wcomma), nmore)
	if nmore ge 1 then buff2(13:19,wcomma(wmore)) = $
		byte(':00.000')#replicate(1,1,nmore)
	wend = where( sleng(wcomma)-1 eq comma(wcomma), nend)
	if nend ge 1 then buff2(9:19,wcomma(wend)) = $
		byte( '0000:00.000')#replicate(1,1,nend)
endif
if nnone ge 1 then buff2(8:19,wnone)=byte(',0000:00.000')#replicate(1,1,nnone)

;replace all of the zeroes with blanks (32b)
;check for characters '/,:.'  
; 47  44  58  46
;change all /,: characters to blanks, 32b

wzero =where(buff2 eq 0b, nzero) ;eliminate 0's
if nzero ge 1 then buff2(wzero) = 32b

buff2( where( (buff2 eq 47b) or (buff2 eq 44b) or (buff2 eq 58b) ,nb)) = 32b
if nb ne n*4 then goto,errorlog ; should be 4 blanks per line

sbuff = string(buff2)
		

ymdhs = dblarr( 5,n)

on_ioerror, errorlog
reads, sbuff, ymdhs ;
on_ioerror, null

ymdhs = transpose( ymdhs) ;for Yohkoh format, year and day are transposed
if ndash ge 1 then begin
	yy = ymdhs(*,0)
	ymdhs(wdash,0) = ymdhs(wdash,2) ;move years to days 
	ymdhs(wdash,2) = yy(wdash) ; move days to years
endif

;VALID FROM 1950-2049
year = [indgen(50)+2000,indgen(50)+1950]
yy = year( ymdhs(*,0) )
hhmm = fix(ymdhs(*,3))
hrs = hhmm/100 + (hhmm mod 100)/60.0d0 + ymdhs(*,4)/3600.0d0
;check ranges

wbad = where(  ( abs(yy-2000) gt 50) or (hrs gt 24.0) or (ymdhs(*,1) gt 12) $
	 or (ymdhs(*,2) gt 31), nbad)
if nbad gt 0 then goto, errorlog
	

jdcnv, yy, fix(ymdhs(*,1)), fix(ymdhs(*,2)), hrs, jd

ut = (jd- 2443874.5d0) * 86400.0d0
ut = double(strmid(utstring,0,0)) + ut(*)

if scalar then ut= ut(0)
;
; Provide users with commonly time and date components
; Date keyword supercedes time keyword
;
case 1 of
 keyword_set(date): ut = ut - (ut mod 86400.d0)
 keyword_set(time): ut = ut mod 86400.d0 
 1:
endcase


error=0
return, ut

errorlog:
;PRINT,'ERROR = ',ERROR
error = 1
print,'Error. Format for time is YY/MM/DD, HHMM:SS.SSS'
print,' or alternatively, DD-Mon-YY HH:MM:SS.SSS'
print, utstring
return, utstring0			;return the input on error, ras 7-jan-94
end
