function  all_vals,array
;+
; NAME:
;	ALL_VALS
; PURPOSE:
;	Return (in ascending order) all the values in an array.
; CALLING SEQUENCE:  
;	out = ALL_VALS(array)
; INPUTS:
;	array	input array
; OUTPUTS:
;	out	Vector containing all the values in the array in 
;		ascending order. Only one of each value returned.
; RESTRICTIONS:
;
; PROCEDURE:
;
; MODIFICATION HISTORY:
;	RDB, MSSL, 11-May-91
;	To emulate a user supplied IDL V1 routine
;-

if n_elements(array) eq 1 then begin
	kko = array
	goto, endit
	endif

kk = array(sort(array))		;sort the input array
jj = kk(1:*)-kk(0:*)		;find repeats (diff=0)

kko = kk([0,where(jj)+1])	;return only single occurances
if max(jj) eq 0  then kko = kk(0:0)

endit:
return,kko

end
