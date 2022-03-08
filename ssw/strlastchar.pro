function strlastchar, array
;
;+
;   Name: strlastchar
;   
;   Purpose: return last non-blank character(s) in a string or string array
;
;   Input Parameters:
;      array - string or string array
;
;   Calling Sequence:
;      lastchar=strlastchar(strarr)
;
;   History:
;      29-jul-1995 (SLF)
;-
;   
; 
barray=byte(array)                        ; byte version
rbarray=reverse(barray)                   ; reverse byte version
null=where(rbarray eq 0b,ncnt)            ; find nulls
if ncnt gt 0 then rbarray(null) = 32b     ; blank fill nulss (avoid truncation)

; now extract the first (character of the reversed array
retval=strmid(strtrim(string(rbarray),2),0,1)
return,retval
end
