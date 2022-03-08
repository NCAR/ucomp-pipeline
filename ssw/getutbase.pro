
FUNCTION GETUTBASE,ARG ;returns the value UTBASE from COMMON UTCOMMON
;+
; NAME:
;	GETUTBASE
; PURPOSE:
;	Function to retrieve value of utbase fromm common UTCOMMON without 
;	   having to declare common.
; CALLING SEQUENCE:
;	RESULT = GETUTBASE()
; INPUTS: 
;	None
; PROCEDURE:
;	GETUT is called to retrieve utbase, See GETUT.PRO description.
; MODIFICATION HISTORY:
;	Written by Richard Schwartz for IDL VERSION 2, Feb. 1991
;-
on_error,2
!quiet=1
GETUT,UTBASE=BASE
RETURN, BASE &END
