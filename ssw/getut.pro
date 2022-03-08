
PRO GETUT,UTBASE=BASE,UTSTART=START,UTEND=END1,STRINGIT=S,PRINTIT=P
on_error,2
!QUIET=1
;+
; NAME:
;	GETUT
; PURPOSE:
;	Retrieve base, start, or end time from common UTCOMMON.  
; CATEGORY:
; CALLING SEQUENCE:
;	GETUT,UTBASE=base,UTSTART=start,UTEND=end ,/STR,/PRI
; INPUTS:
;	None.
; INPUT PARAMETERS:
;	BASE, START, END - keyword parameters select which time(s) to retrieve,
;	   times returned are double precision seconds relative to 79/1/1, 0000
;	   or string if /STRINGIT is specified
;	/STRINGIT - return times in strings with format YY/MM/DD,HHMM:SS.XXX 
;	/PRINT - print times on the terminal (prints all three if none are 
;	   specified)
; COMMON BLOCKS:
;	COMMON UTCOMMON, UTBASE, UTSTART, UTEND = base, start, and 
;	   end time for X axis in double precision variables containing
;	   seconds since 79/1/1, 00:00.
;	COMMON LASTDATECOM, LASTDATE = YY/MM/DD string for last entry
;	   into SETUT
; SIDE EFFECTS:
;	None.
; RESTRICTIONS:
;	None.
; PROCEDURE:
;	ATIME is called to translate UTXXX to YY/MM/DD, HHMM:SS.XXX string
;	UTBASE is epoch day * 86400 + msec/1000 from 79/01/01
; MODIFICATION HISTORY:
;	Written by Richard Schwartz for IDL Version 2, Feb. 1991
;-
;
COMMON UTCOMMON,UTBASE,UTSTART,UTEND
;ARE THE VARIABLES SET, IF NOT THEN SET TO ZERO
CHECKVAR,UTBASE,0.D0
CHECKVAR,UTSTART,0.D0
CHECKVAR,UTEND,0.D0
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Set the right variable in common
BASE=UTBASE
START=UTSTART
END1=UTEND
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
IF KEYWORD_SET(S) THEN BEGIN
	BASE=ATIME(BASE)
	START=ATIME(START)
	END1=ATIME(END1)
ENDIF
IF KEYWORD_SET(P) THEN BEGIN
PRINT,'UTBASE =  ',BASE
PRINT,'UTSTART = ',START
PRINT,'UTEND =   ',END1
ENDIF
RETURN
END
