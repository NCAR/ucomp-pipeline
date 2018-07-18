
FUNCTION GETUTBASE,ARG ;returns the value UTBASE from COMMON UTCOMMON
;+
; NAME:
;	GETUTBASE
; PURPOSE:
;	Function to retrieve value of utbase fromm common UTCOMMON without 
;	   having to declare common.  Returns in UTIME format, sec from 79/1/1
;
; CALLING SEQUENCE:
;	RESULT = GETUTBASE()
; INPUTS: 
;	None
; PROCEDURE:
;	GETUT is called to retrieve utbase, See GETUT.PRO description.
; MODIFICATION HISTORY:
;	Written by Richard Schwartz for IDL VERSION 2, Feb. 1991
;	mod 1-nov-91 to accept all representations of the base time, ras
;-
on_error,2

GETUT,UTBASE=BASE
RETURN, base ;already in sec from 79/1/1

END
