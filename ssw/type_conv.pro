pro type_conv, input_output, sample_type, type
;
;+
;NAME:
;	type_conv
;PURPOSE:
;	Perform a variable type conversion.  It is used
;	in conjuction with the "INPUT" routine
;INPUT/OUTPUT:
;	input_output - The value to be converted
;INPUT:
;	sample_type  - The variable type that needs to be
;			matched
;OUTPUT:
;	type	     - The variable type (IDL convention)
;HISTORY:
;	Written 1988 by M.Morrison
;-
;
siz=size(sample_type)
type=siz( siz(0)+1 )
;
case type of
    0: input_output = -1
    7: input_output = string(input_output)	;string
    1: input_output = byte(input_output)	;byte
    2: input_output = fix(input_output)		;integer	(INTEGER*2)
    4: input_output = float(input_output)	;real		(REAL*4)
    3: input_output = long(input_output)	;longword	(INTEGER*4)
    5: input_output = double(input_output)	;double prec	(REAL*8)
    6: input_output = complex(input_output)	;complex	(2 REAL*4)
endcase
;
return
end
