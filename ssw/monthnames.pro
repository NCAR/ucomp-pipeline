;-------------------------------------------------------------
;+
; NAME:
;       MONTHNAMES
; PURPOSE:
;       Returns a string array of month names.
; CATEGORY:
; CALLING SEQUENCE:
;       mnam = monthnames()
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       mnam = string array of 13 items:     out
;         ['Error','January',...'December']
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 18 Sep, 1989
;
; Copyright (C) 1989, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	function monthnames, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Returns a string array of month names.'
	  print,' mnam = monthnames()'
	  print,'   mnam = string array of 13 items:     out'
	  print,"     ['Error','January',...'December']"
	  return, -1
	endif
 
	mn = ['Error','January','February','March','April','May',$
	      'June','July','August','September','October',$
	      'November','December']
 
	return, mn
	end
