	pro ieee2vax, variable
;****************************************************************************
;+
; NAME:
;    ieee2vax
; PURPOSE:
;    To convert Unix IDL floating/double to VAX IDL data types.
; CALLING SEQUENCE:
;    ieee2vax, variable
; PARAMETERS:
;    variable - The data variable to be converted.  This may be a scalar
;	 or an array.
; RESTRICTIONS:
;	Only tested for data from IEEE standard Unix machines (e.g. SUN0
; MODIFICATION HISTORY:
;	Version 1	By John Hoegy		13-Jun-88
;	04-May-90 - WTT:  Created CONV_UNIX_VAX from VAX2SUN, reversing floating
;			  point procedure.
;       09-Sep-91 - TRM:  Caniballized CONV_UNIX_VAX
;	19-May-93 - MDM:  Replace call to SWAP with a call to BYTEORDER
;-
;****************************************************************************
;
;  Check to see if VARIABLE is defined.
;
if n_elements(variable) eq 0 then begin
	print,'*** VARIABLE not defined, routine ieee2vax.'
	retall
endif
;
var_chars = size(variable)
var_type = var_chars(var_chars(0)+1)
;
case var_type of
  1: return			        ; byte
  2: return                             ; integer
  3: return                             ; longword
  4: begin         		        ; floating point
        scalar = (var_chars(0) eq 0)
        var_elems = long(var_chars(var_chars(0)+2))
        byte_elems = var_elems*4L
        if scalar then begin
	    tmp = fltarr(1)
            tmp(0) = variable
            byte_eq = byte(tmp, 0, byte_elems)
            endif else byte_eq = byte(variable, 0, byte_elems)
    ;
        i1 = lindgen(byte_elems/4L)*4L
        i2 = i1 + 1L
        biased = byte((byte_eq(i1) AND '7F'X) * 2) OR byte(byte_eq(i2)/128L)
        i = where(biased ne 0)
        if (i(0) ne -1) then biased(i) = byte(biased(i) + 2)
        byte_eq(i1) = byte(byte_eq(i1) AND '80'X) OR byte(biased/2)
        byte_eq(i2) = byte(byte_eq(i2) AND '7F'X) OR byte(biased*128)
    ; 
    ; swap bytes
    ;
        byte_elems = byte_elems + 3L
        ;;swap,byte_eq
        byteorder, byte_eq, /sswap	;MDM replace SWAP with BYTEORDER 19-May-93
;
        if scalar then begin
           tmp = fltarr(1)
           tmp(0) = float(byte_eq, 0, var_elems)
           variable = tmp(0)
           endif else variable(0) = float(byte_eq, 0, var_elems)
        return & end
  5: begin    	         	; double precision
        var_elems = long(var_chars(var_chars(0)+2))
        byte_elems = var_elems*8L
	scalar = (var_chars(0) eq 0)
        if scalar then begin
             tmp = dblarr(1)
	     tmp(0) = variable
      	     byte_eq = byte(tmp, 0, byte_elems)
             endif else byte_eq = byte(variable, 0, byte_elems)
    ;
    ;  Bring it up to at least a double-precision level.
    ;
       byte_elems = byte_elems + 7L
       i1 = lindgen(byte_elems/8L)*8L
       i2 = i1 + 1L
       i3 = i2 + 1L
       I4 = i3 + 1L
       i5 = i4 + 1L
       i6 = i5 + 1L
       i7 = i6 + 1L
       i8 = i7 + 1L
       exponent = fix( ((byte_eq(i1) AND '7F'X)*16) OR $
 		    ((byte_eq(i2) AND 'F0'X)/16) )
       i = where(exponent ne 0)
       if (i(0) ne -1) then exponent(i) = exponent(i) + 128 - 1022
       tmp1 = byte_eq(i8)
       byte_eq(i8) = ((byte_eq(i7) and '1f'x)*8) or ((tmp1 and 'e0'x)/32)
       tmp2 = byte_eq(i7)
       byte_eq(i7) = (tmp1 and '1f'x)*8
       tmp3 = byte_eq(i6)
       byte_eq(i6) = ((byte_eq(i5) and '1f'x)*8) or ((tmp3 and 'e0'x)/32)
       tmp1 = byte_eq(i5)
       byte_eq(i5) = ((tmp3 and '1f'x)*8) or ((tmp2 and 'e0'x)/32)
       tmp2 = byte_eq(i4)
       byte_eq(i4) = ((byte_eq(i3) and '1f'x)*8) or ((tmp2 and 'e0'x)/32)
       tmp3 = byte_eq(i3)
       byte_eq(i3) = ((tmp2 and '1f'x)*8) or ((tmp1 and 'e0'x)/32)
       tmp1 = byte_eq(i2)
       byte_eq(i2) = (byte_eq(i1) and '80'x) or byte((exponent and 'fe'x)/2)
       byte_eq(i1) = byte((exponent and '1'x)*128) or ((tmp1 and 'f'x)*8) or $
             ((tmp3 and 'e0'x)/32)
;
       if scalar then begin
           tmp = dblarr(1)
           tmp(0) = double(byte_eq, 0, var_elems)
           variable = tmp(0)
           endif else variable(0) = double(byte_eq, 0, var_elems)
       return & end
  6: return                     ; complex
  7: return                     ; string
  else: begin			; unknown
       print,'*** Data type ' + strtrim(var_type,2) + $
                  ' unknown, routine ieee2vax.'
       retall
       end
  endcase
return
end

