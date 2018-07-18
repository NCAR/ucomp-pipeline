pro dec2sun, ainput

;+
;NAME:
;	dec2sun
;PURPOSE:
;	Converts data written on a DEC machine to SUN format by swapping
;	bytes appropriately for the type of the input data.  The data
;       on the DEC machine is assumed to be IEEE format with the byte
;       order reversed: this is *not* VAX format!  The routine converts
;       between data from a DECStation and a Sun.  Since both use IEEE
;       format, dec2sun will also convert from sun format to DEC format.
;CATEGORY:
;	Byte-swapping
;CALLING SEQUENCE:
;	dec2sun,a
;INPUTS:
;	a = input variable which is to have its bytes swapped
;OPTIONAL INPUT PARAMETERS:
;	none
;KEYWORD PARAMETERS
;	none
;OUTPUTS:
;	a = reformatted variable is passed back in the original variable
;COMMON BLOCKS:
;	None
;SIDE EFFECTS:
;	None
;RESTRICTIONS:
;	None
;PROCEDURE:
;	Determines the type of the variable and swaps the bytes depending
;	on the type.  If the variable is a structure, the tags are 
;	recursively searched so that the bytes are swapped throughout
;	the structure.
;MODIFICATION HISTORY:
;	T. Metcalf 5/20/91  Version 1.0
;
;       T. Metcalf Aug 1991: Added complex floating point  Version 1.1
;       T. Metcalf Nov 1991: Converted vax2sun to dec2sun
;	29-Jun-94 (MDM) - Modified to preserve the dimensions when
;			  working on double precision data
;	14-Nov-95 (MDM) - Modified to allow double precision array in
;			  an structure array.
;       Circa 1-jan-2014 - Paul Boerner, couple indgen->lindgen, as required for IRIS
;-

   a = ainput  ; Protect the input variable in case of error

   sofa = size(a)
   ns = n_elements(sofa)

   ; If not a structure, then swap bytes

   if (sofa(ns-2) NE 8) then begin
      case sofa(ns-2) of
       0:                                  ; Undefined
       1:                                  ; Byte
       2: byteorder,a,/sswap               ; Integer
       3: byteorder,a,/lswap               ; Longword integer
       4: byteorder,a,/lswap               ; Floating Point
       5: begin                            ; Double precision floating point
             byteorder,a,/lswap        
             na = n_elements(a)
             longa=long(a,0,2*na)
             longb=lonarr(2*na,/nozero)
             even = lindgen(na)*2
             odd = even+1
	     longb(even)=longa(odd)
             longb(odd)=longa(even)
             ;;a = double(longb,0,na)		;MDM removed 29-Jun-94
             case sofa(0) of
		2: a = double(longb,0,sofa(1),sofa(2))
		3: a = double(longb,0,sofa(1),sofa(2),sofa(3))
		4: a = double(longb,0,sofa(1),sofa(2),sofa(3),sofa(4))
		else: a = double(longb,0,na)
	     endcase
	     if (sofa(0) eq 2) then a = reform(a, sofa(1), sofa(2), /overwrite)		;MDM 14-Nov-95
          end
       6: begin                            ; Complex floating point
            rc=float(a)
            ic=imaginary(a)
            byteorder,rc,/lswap
            byteorder,ic,/lswap
            a = complex(rc,ic)
          end
       7:                                  ; String
       else: print,'WARNING: dec2sun: Unknown type code'
      endcase
   endif $
   else begin
      na = sofa(ns-1)

      ; In the case of a structure, search all the fields (recursively if 
      ; necessary) to swap all bytes which need swapping in the structure.

      for tag = 0, n_tags(a)-1 do begin

         temp = a.(tag)      ; byteorder won't work on a structure field
         sofa = size(temp)
         ns = n_elements(sofa)
         case sofa(ns-2) of
          0:                                  ; Undefined
          1:                                  ; Byte
          2: byteorder,temp,/sswap            ; Integer
          3: byteorder,temp,/lswap            ; Longword integer
          4: byteorder,temp,/lswap            ; Floating Point
          5: begin                            ; Double precision floating point
                byteorder,temp,/lswap        
                ntemp = n_elements(temp)
                longa=long(temp,0,2*ntemp)
                longb=lonarr(2*ntemp,/nozero)
                even = lindgen(ntemp)*2
                odd = even+1
                longb(even)=longa(odd)
                longb(odd)=longa(even)
                temp = double(longb,0,ntemp)
		if (sofa(0) eq 2) then temp = reform(temp, sofa(1), sofa(2), /overwrite)	;MDM 14-Nov-95
             end
          6: begin                            ; Complex floating point
               rc=float(temp)
               ic=imaginary(temp)
               byteorder,rc,/lswap
               byteorder,ic,/lswap
               temp = complex(rc,ic)
             end
          7:                                  ; String
          8: dec2sun, temp                    ; Structure (recursive)
          else: print,'WARNING: dec2sun: Unknown type code'
         endcase
         a.(tag) = temp
   
      endfor

   endelse

   ainput = a

end
