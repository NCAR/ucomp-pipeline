;-------------------------------------------------------------
;+
; NAME:
;       MORE
; PURPOSE:
;       Display a text array using the MORE method.
; CATEGORY:
; CALLING SEQUENCE:
;       more, txtarr
; INPUTS:
;       txtarr = string array to display.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         /NUMBERS means display line numbers.
;         FORMAT=fmt  specify format string (def=A).
;           Useful for listing numeric arrays, ex:
;           more,a,form='f8.3'  or  more,a,form='3x,f8.3'
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: when screen is full output will pause
;        until user presses SPACE to continue.
; MODIFICATION HISTORY:
;       R. Sterner, 26 Feb, 1992
;       Jayant Murthy murthy@pha.jhu.edu 31 Oct 92 --- added FORMAT keyword.
;       R. Sterner, 29 Apr, 1993 --- changed for loop to long int.
;	25-Apr-94 (M.Morrison) - Added "on_ioerror" because it was crashing
;	on SGI machine at "FREE_LUN" command (even though it closed properly)
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro more, txt, help=hlp, numbers=num, format=fmt
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display a text array using the MORE method.'
	  print,' more, txtarr'
	  print,'   txtarr = string array to display.  in'
	  print,' Keywords:'
	  print,'   /NUMBERS means display line numbers.'
	  print,'   FORMAT=fmt  specify format string (def=A).
	  print,'     Useful for listing numeric arrays, ex:
	  print,"     more,a,form='f8.3'  or  more,a,form='3x,f8.3'"
	  print,' Note: when screen is full output will pause'
	  print,'  until user presses SPACE to continue.'
	  return
	endif
 
	if n_elements(fmt) eq 0 then fmt='a'
 
	scrn = filepath(/TERMINAL)
 
	openw,lun,scrn,/more,/get_lun
 
	if keyword_set(num) then begin
	  for i = 0L, n_elements(txt)-1 do begin
	    printf,lun,i,txt(i),form='(i5,2x,'+fmt+')'
	  endfor
	endif else begin
	  for i = 0L, n_elements(txt)-1 do printf,lun,txt(i),form='('+fmt+')'
	endelse

on_ioerror, error 
	free_lun, lun
error:
	return
	end
