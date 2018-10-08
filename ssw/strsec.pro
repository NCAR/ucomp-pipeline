;-------------------------------------------------------------
;+
; NAME:
;       STRSEC
; PURPOSE:
;       Convert seconds after midnight to a time string.
; CATEGORY:
; CALLING SEQUENCE:
;       tstr = strsec(sec, [d])
; INPUTS:
;       sec = seconds after midnight.             in
;         Scalar or array.
;       d = optional denominator for a fraction.  in
; KEYWORD PARAMETERS:
;       Keywords:
;          /HOURS forces largest time unit to be hours instead of days.
; OUTPUTS:
;       tstr = resulting text string.             out
; COMMON BLOCKS:
; NOTES:
;       Notes: Output is of the form: [DDD/]hh:mm:ss[:nnn/ddd]
;         where DDD=days, hh=hours, mm=minutes, ss=seconds,
;         nnn/ddd=fraction of a sec given denominator ddd in call.
;         If sec is double precision then 1/10 second can be
;         resolved in more than 10,000 days.  Use double precision when
;         possible. Time is truncated, so to round to nearest second,
;         when not using fractions, add .5 to sec.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 8 Jan, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES --- Added day: 21 Feb, 1985.
;       RES 19 Sep, 1989 --- converted to SUN
;       RES 18 Mar, 1990 --- allowed arrays.
;       TRM 08 May, 1991 --- changed array to array_jhuapl
;
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	FUNCTION STRSEC,SEC0,D, help=hlp, hours=hrs
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert seconds after midnight to a time string.'
	  print,' tstr = strsec(sec, [d])'
	  print,'    sec = seconds after midnight.             in'
	  print,'      Scalar or array.
	  print,'    d = optional denominator for a fraction.  in'
	  print,'    tstr = resulting text string.             out'
	  print,' Keywords:'
	  print,'    /HOURS forces largest time unit to be hours '+$
	    'instead of days.'
	  print,' Notes: Output is of the form: [DDD/]hh:mm:ss[:nnn/ddd]'
	  print,'   where DDD=days, hh=hours, mm=minutes, ss=seconds,'
	  print,'   nnn/ddd=fraction of a sec given denominator ddd in call.'
	  print,'   If sec is double precision then 1/10 second can be'
	  print,'   resolved in more than 10,000 days.  Use double precision'+$
	    ' when'
	  print,'   possible. Time is truncated, so to round to nearest '+$
	    'second,'
	  print,'   when not using fractions, add .5 to sec.'
	  return, -1
	endif
 
	aflag = isarray(sec0)		; Is input an array? (0=no, 1=yes).
	seca = array_jhuapl(sec0)	; Force input to be an array.
	nn = n_elements(seca)		; Number of elements in input array.
	out = strarr(nn)		; Output string array.
 
	;-------------------------------------------------------------------
	for ii = 0, nn-1 do begin	; Loop through all input elements.
	sec = seca(ii)			; Pull out the ii'th element.
	T = double(SEC)			; Convert to double.
	DY = LONG(T/86400)		; # days.
	T = T - 86400*DY		; Time without days.
	H = LONG(T/3600)		; # hours.
	T = T - 3600*H			; Time without hours.
	if keyword_set(hrs) then begin	; If /HOURS then convert days to hours.
	  h = h + 24*dy
	  dy = 0
	endif
	M = LONG(T/60)			; # minutes.
	T = T - 60*M			; Time without minutes.
	S = LONG(T)			; Seconds.
	F = T - S			; Time without seconds (=fraction).
 
	SDY = ''			; Day part of string, def=null.
	IF DY GT 0 THEN BEGIN		; Convert day to 3 digit day number.
	  SDY = STRTRIM(STRING(DY),2)
	  IF DY LT 10  THEN SDY = '0'+SDY
	  IF DY LT 100 THEN SDY = '0'+SDY
	  SDY = SDY+'/'			; Want / after day number.
	ENDIF
	SH = STRTRIM(STRING(H),2)	; Convert hours to string.
	IF H LT 10 THEN SH = '0'+SH	; Add leading 0 if needed.
	SM = STRTRIM(STRING(M),2)	; Convert minutes to string.
	IF M LT 10 THEN SM = '0'+SM	; Add leading 0 if needed.
	SS = STRTRIM(STRING(S),2)	; Convert seconds to string.
	IF S LT 10 THEN SS = '0'+SS	; Add leading 0 if needed.
 
	SHMS = SDY+SH+':'+SM+':'+SS	; Put parts together.
 
;	IF N_PARAMS(0) LT 2 THEN RETURN, SHMS
	IF N_PARAMS(0) ge 2 THEN begin		; Also want fraction of second.
	  SD = STRTRIM(STRING(D),2)		; Convert denom. to string.
	  LN = STRLEN(STRTRIM(STRING(D-1),2))
	  N = LONG(D*F+.5)			; Find numerator.
	  SN = STRTRIM(STRING(N),2)		; Convert numerator to string.
LOOP:	  IF STRLEN(SN) GE LN THEN GOTO, FINISH	; Numerator in correct form?
	  SN = '0'+SN				; Add leading 0s to numerator.
	  GOTO, LOOP
FINISH:   SHMS = SHMS+':'+SN+'/'+SD		; Tack on fraction as a string.
	endif
 
	out(ii) = shms
 
	endfor
	;-------------------------------------------------------------------
 
	if aflag eq 0 then out = out(0)		; Handle scalar.
 
	RETURN, out
 
	END
