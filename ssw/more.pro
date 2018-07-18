; -------------------------------------------------------------
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
;	8-feb-1998, richard.schwartz@gsfc.nasa.gov,
;	  Added protection for windows and macs, which do not support filepath(/terminal).
;	  Send text to a standard IDL text widget, XDISPLAYFILE, instead.
;	25-Jul-2001, Kim.tolbert@gsfc.nasa.gov, added font=fixedsys on xdisplayfile call
;	30-Aug-2002, mimster@stars.gsfc.nasa.gov, added compatibility for IDLDE for unix
;
; Copyright (C) 1992, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
; -------------------------------------------------------------

	pro more, txt, help=hlp, numbers=num, format=fmt

        ;checking for the isagui tag in fstat
        fst=0
        IF tag_exist(fstat(0), 'isagui') THEN fst=(fstat(0)).isagui

	case 1 of
	(os_family() eq 'vms' or os_family() eq 'unix') and (not(fst)):begin    ;added check for idlde
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
	end
	  else: begin
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display a text array in XDISPLAYFILE. '
	  print,' Standard terminal emulation not applicable on Windows or MacOS.'
	  print,' more, txtarr'
	  print,'   txtarr = string array to display.  in'
	  print,' Keywords:'
	  print,'   /NUMBERS means display line numbers.'
	  print,'   FORMAT=fmt  specify format string (def=A).
	  print,'     Useful for listing numeric arrays, ex:
	  print,"     more,a,form='f8.3'  or  more,a,form='3x,f8.3'"

	  return
	endif


	if n_elements(fmt) eq 0 then fmt='a'

	text_display = strarr(n_elements(txt))




	if keyword_set(num) then $
	  for i = 0L, n_elements(txt)-1 do $
	    text_display(i) = string(/print,i,txt(i),form='(i5,2x,'+fmt+')') $
	else $
	  for i = 0L, n_elements(txt)-1 do $
	    text_display(i) = string(/print,txt(i), form='('+fmt+')')
	;fixedsys font for windows or default for unix
	IF os_family() EQ 'Windows' THEN ont='fixedsys' ELSE IF os_family() EQ 'unix' THEN ont=''
	xdisplayfile,'',text=text_display, title=!version.os+' More ', font=ont
		end
	  endcase


error:
	return
	end
