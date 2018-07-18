
PRO GETUT,UTBASE=BASE,UTSTART=START,UTEND=END1,XSTART=XSTART, STRINGIT=S,PRINTIT=P
on_error,2
; !quiet=1
;+
; NAME:
;	GETUT
; PURPOSE:
;	Retrieve base, start, or end time from common UTCOMMON.  
; CATEGORY:
; CALLING SEQUENCE:
;	GETUT,UTBASE=base,UTSTART=start,UTEND=end ,XSTart = xstart, /STR,/PRI
; INPUTS:
;	None.
; INPUT PARAMETERS:
;	BASE, START, END, XSTART - keyword parameters select which time(s) to retrieve,
;	   times returned are double precision seconds relative to 79/1/1, 0000
;	   or string if /STRINGIT is specified
;	/STRINGIT - return times in strings with format YY/MM/DD,HHMM:SS.XXX 
;	/PRINT - print times on the terminal (prints all three if none are 
;	   specified)
; COMMON BLOCKS:
;	COMMON UTCOMMON, UTBASE, UTSTART, UTEND, XST = base, start, and 
;	   end time for X axis in double precision variables containing
;	   seconds since 79/1/1, 00:00.  XST is the fully referenced time
;	   of the start of the plot in any supported format.
; SIDE EFFECTS:
;	None.
; RESTRICTIONS:
;	None.
; PROCEDURE:
;	ATIME is called to translate UTXXX to YY/MM/DD, HHMM:SS.XXX string
;	UTBASE is epoch day * 86400 + msec/1000 from 79/01/01
; MODIFICATION HISTORY:
;	Written by Richard Schwartz for IDL Version 2, Feb. 1991
;	RAS, modified for Yohkoh Environment, 1-Nov-1993
;-
;
@utcommon
; COMMON UTCOMMON,UTBASE,UTSTART,UTEND, xst

;ARE THE VARIABLES SET, IF NOT THEN SET TO ZERO
CHECKVAR,UTBASE,0.D0
CHECKVAR,UTSTART,0.D0
CHECKVAR,UTEND,0.D0
checkvar,xst, 0.d0
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Set the right variable in common
BASE=anytim(UTBASE, out='utime')
START=anytim(utstart,out='utime')
END1=anytim(UTEND, out='utime')
xstart = anytim( xst, out='utime')
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
IF KEYWORD_SET(S) THEN BEGIN
	BASE=ATIME(BASE, /pub)
	START=ATIME(START,/pub)
	END1=ATIME(END1,/pub)
	xstart =atime( xstart,/pub ) 
ENDIF
IF KEYWORD_SET(P) THEN BEGIN
	PRINT,'UTBASE =  ',BASE
	PRINT,'UTSTART = ',START
	PRINT,'UTEND =   ',END1
	print,'XST   =   ',xstart
ENDIF
RETURN
END
