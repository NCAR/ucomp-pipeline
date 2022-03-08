function str_lastpos, source, substring
;
;+
;   Name: str_lastpos  
; 
;   Purpose: find last occurence of a substring in the source string
;
;   Input Paramters:
;      source - string or string array to search
;      substring - string to search for
;
;   Output:
;      return value is position in string or -1 if not present
;
;   History: slf, 11/1/91
;	     modified, 11/19/91 to allow string arrays for source
;- 
;
rev_bytes=reverse(byte(source)) 
;
; since byte operation will generate nulls for array padding,
; terminators must be purged before converting back to string
;
terminators=where(rev_bytes eq 0)
if terminators(0) ge 0 then rev_bytes(terminators) = 32
;
rev_string=strtrim(string(rev_bytes),2)
rev_substring=string(reverse(byte(substring)))
;
; use standard strpos on now reversed operands
backpos=strpos(rev_string, rev_substring)
found=where(backpos ge 0)
if found(0) ge 0 then backpos(found) = $
   strlen(source(found)) - backpos(found) - strlen(substring(found))
;
return,backpos
end
