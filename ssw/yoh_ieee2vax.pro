pro yoh_ieee2vax, a
;
;+
; NAME:
;	yoh_ieee2vax
; PURPOSE:
;	To convert Unix IDL floating/double to VAX IDL data types.
; CALLING SEQUENCE:
;	yoh_ieee2vax, a
; PARAMETERS:
;	a - The data variable to be converted.  This may be a scalar
;	    or an array.
; RESTRICTIONS:
;	Only tested for data from IEEE standard Unix machines (e.g. SUN)
;		*** Double precision does not work ***
; MODIFICATION HISTORY:
;	Written 13-Apr-93 by M.Morrison
;	 6-May-93 (MDM) - Fixed a typo
;-
;
;  Check to see if A is defined.
;
if n_elements(a) eq 0 then begin
    print,'YOH_IEEE2VAX: *** A not defined'
    return
endif
;
var_chars = size(a)
var_type = var_chars(var_chars(0)+1)
;
case var_type of
  1: return			        ; byte
  2: return                             ; integer
  3: return                             ; longword
  4: begin         		        ; floating point
	dec2sun, a					;swap them because IEEE2VAX swaps them ?
	ieee2vax, a					;do the conversion
	return
     end
  5: begin    	         	; double precision
	dec2sun, a					;swap them because IEEE2VAX swaps them ?
	ieee2vax, a					;do the conversion
	return
     end
  6: return                     ; complex
  7: return                     ; string
  else: begin			; unknown
	for tag = 0, n_tags(a)-1 do begin
	    temp = a.(tag)      ; byteorder won't work on a structure field
	    yoh_ieee2vax, temp
	    a.(tag) = temp
	endfor
	return
     end
endcase
;
return
end


