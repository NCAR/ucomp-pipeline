function mask, ibyte, stbit, nbit
;
;+
;NAME:
;	mask
;PURPOSE:
;	To return the value of masked bits
;CALLING SEQUENCE:
;	out = mask(value, 0, 2)		- low two bits
;	out = mask(value, 6, 2)		- high two bits
;INPUT:
;	ibyte	- the scalar or vector value
;	stbit	- the starting bit
;	nbit	- then number of bits to extract
;HISTORY:
;	Written Fall '91 by M.Morrison
;	16-Nov-95 (MDM) - Modified so it would work with long words
;
;
;;return, (long(ibyte) / (long(2)^stbit)) mod (long(2)^nbit)
return, ishft(ibyte, -stbit) and (long(2)^(nbit)-1)
end

