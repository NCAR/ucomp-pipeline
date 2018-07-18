
pro vax2ieee, vinput

;+
;  NAME:
;       vax2ieee
;  PURPOSE:
;       To convert VAX floating point to Sun IEEE floating point
;  CALLING SEQUENCE:
;       vax2ieee, variable
;  INPUTS:
;       variable - The data variable to be converted.  This may be a scalar
;                  or an array.  Valid datatypes are floating point, and 
;                  double precision.
;  OUTPUTS:
;       variable - The result of the conversion is passed back in the
;                  original variable.
;  COMMON BLOCKS:
;       none
;  SIDE EFFECTS:
;       none
;  RESTRICTIONS:
;       Only floating point arrays or scalars are converted, others are
;       unchanged.
;  MODIFICATION HISTORY:
;
;       Version 1       By John Hoegy           13-Jun-88
;
;       21-Oct-88 - JAH:  Fixed problem where it wouldn't convert float
;                         and double scalars.
;
;       24-Oct-88 - JAH:  Fixed problem with converting integer arrays.
;
;       21-May-91 - T. Metcalf:  Cannibalized vax_to_sun to get IEEE conversions
;                                See also vax2sun.pro
;-


   variable = vinput    ; Protect the input in case of error

   var_chars = size(variable)
   var_type = var_chars(var_chars(0)+1)
   var_elems = long(var_chars(var_chars(0)+2))

   case var_type of
    0: return                           ; Undefined
    1: return                           ; Byte
    2: return                           ; Integer
    3: return                           ; Longword integer
    4: single=1                         ; Floating Point
    5: single=0                         ; Double precision floating point
    6: return                           ; Complex floating point
    7: return                           ; String
    8: return                           ; Structure (recursive)
    else: return
   endcase


   if single then begin

   ; Single precision  4-byte

      byte_elems = var_elems*4L

      if var_chars(0) eq 0 then begin
          tmp = fltarr(1)
          tmp(0) = variable
          byte_eq = byte(tmp, 0, byte_elems)
      endif else begin
          byte_eq = byte(variable, 0, byte_elems)
      endelse

      ;
      ;  Make sure this is long enough to get all the elements for the
      ;  conversion.  If the number of bytes required isn't exactly divisible
      ;  by four, it is possible to lose up to the last four elements.  The
      ;  statement below makes sure the byte length is at least on a 4-byte
      ;  boundry.
      ;
      ;  Any extra bytes will just be lost, because they won't be converted
      ;  back into longwords.
      ;
      byte_elems = byte_elems + 3L

      i1 = lindgen(byte_elems/4L)*4L
      i2 = i1 + 1L
      i3 = i2 + 1L
      i4 = i3 + 1L

      tmp = byte_eq(i1) & byte_eq(i1) = byte_eq(i2) & byte_eq(i2) = tmp
      tmp = byte_eq(i3) & byte_eq(i3) = byte_eq(i4) & byte_eq(i4) = tmp

      biased = byte((byte_eq(i1) AND '7F'X) * 2) OR byte(byte_eq(i2)/128L)
      i = where(biased ne 0)
      if ((size(i))(0) ne 0) then biased(i) = byte(biased(i) - 2)

      byte_eq(i1) = byte(byte_eq(i1) AND '80'X) OR byte(biased/2)
      byte_eq(i2) = byte(byte_eq(i2) AND '7F'X) OR byte(biased*128)

      if var_chars(0) eq 0 then begin
          tmp = fltarr(1)
          tmp(0) = float(byte_eq, 0, var_elems)
          variable = tmp(0)
      endif else begin
          variable(0) = float(byte_eq, 0, var_elems)
      endelse

   endif $
   else begin

   ; Double precision  8-byte

      byte_elems = var_elems*8L

      if var_chars(0) eq 0 then begin
          tmp = dblarr(1)
          tmp(0) = variable
          byte_eq = byte(tmp, 0, byte_elems)
      endif else begin
          byte_eq = byte(variable, 0, byte_elems)
      endelse

      ;
      ;  Bring it up to at least a double-precision level.
      ;
      byte_elems = byte_elems + 7L

      i1 = lindgen(byte_elems/8L)*8L
      i2 = i1 + 1L
      i3 = i2 + 1L
      i4 = i3 + 1L
      i5 = i4 + 1L
      i6 = i5 + 1L
      i7 = i6 + 1L
      i8 = i7 + 1L

      tmp = byte_eq(i2) AND '80'X

      exponent = fix( ((byte_eq(i2) AND '7F'X)*2) OR $
                      ((byte_eq(i1) AND '80'X)/128) )
      i = where(exponent ne 0)
      if ((size(i))(0) ne 0) then exponent(i) = exponent(i) - 128 + 1022

      tmp = tmp OR ((exponent AND '7F0'X)/16)
      byte_eq(i2) = (exponent AND '00F'X)*16
      tmp2 = byte_eq(i8)
      byte_eq(i8) = ((byte_eq(i8) AND '07'X)*32) OR ((byte_eq(i7) AND 'F8'X)/8)
      tmp3 = byte_eq(i7)
      byte_eq(i7) = ((byte_eq(i5) AND '07'X)*32) OR ((tmp2 AND 'F8'X)/8)
      tmp2 = byte_eq(i6)
      byte_eq(i6) = ((byte_eq(i6) AND '07'X)*32) OR ((byte_eq(i5) AND 'F8'X)/8)
      tmp3 = byte_eq(i5)
      byte_eq(i5) = ((byte_eq(i3) AND '07'X)*32) OR ((tmp2 AND 'F8'X)/8)
      tmp2 = byte_eq(i4)
      byte_eq(i4) = ((byte_eq(i4) AND '07'X)*32) OR ((byte_eq(i3) AND 'F8'X)/8)
      tmp3 = byte_eq(i3)
      byte_eq(i3) = ((byte_eq(i1) AND '07'X)*32) OR ((tmp2 AND 'F8'X)/8)
      byte_eq(i2) = byte_eq(i2) OR ((byte_eq(i1) AND '78'X)/8)
      byte_eq(i1) = tmp

      if var_chars(0) eq 0 then begin
          tmp = dblarr(1)
          tmp(0) = double(byte_eq, 0, var_elems)
          variable = tmp(0)
      endif else begin
          variable(0) = double(byte_eq, 0, var_elems)
      endelse


   endelse

   vinput = variable

end
