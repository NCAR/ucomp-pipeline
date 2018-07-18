function path_delimiter, os=os
;
;+
;   Name: path_delimiter
;
;   Purpose: return system dependent !path delimiter
;
;   Input Parameters:
;     NONE
;   
;   Keyword Parameters:
;     OS - used for getting other OS delimiters
;
;   Calling Sequence:
;     pdelim=path_delimiter()       ; one for this OS
;     pdelim=path_delimiter(os=xxx) ; test other OS
;
;   History:
;      2-April-1998 - replace corrupted version in SSW
;
;   Calls:
;      os_family  
;-
;
if not keyword_set(os) then os=os_family()

; ------- to extend, append  to BOTH  lists -----

;        def   vms   Wind
delim=([':',  ',',  ';'])(where(os eq ['vms','Windows'])+1)

return,delim
end
