function strmids, inarray, start_position, exlength 
;+ 
;   Name: strmids
;
;   Purpose: strmid with vectorized parameters
;
;   Input Parameters:
;      inarry  - initial string array to split
;      start_position - first position (array ok)
;      exlength - length to extract (array ok)
;
;   Output:
;      function return value is trimmed string array 
;
;   Calling Sequence:
;      strarr=strmid(inarray, start_positions, exlength )
;
;   Calling Examples:
;    IDL> more,strmids(replicate('123456789',5), indgen(5), indgen(5)+1 )
;           1
;           23
;           345
;           4567
;           56789
;
; 
;   History:
;      12-sep-1997 - S.L.Freeland 
;      16-sep-1997 - S.L.Freeland - ignore action for any '-1' paramters
;                                   (allow strpos direct pass through)  
;      17-sep-1997 - S.L.Freeland - dont bother initializing output array
;
;   Method:
;      calls strmid - vectorized for uniq combinations of 
;                     of start position and length  
;-
; ----------- check input -------------------
if not data_chk(inarray,/string) then begin
   message,/info,"Need input string or string array
   return,''
endif
narr=n_elements(inarray)
; --------------------------------------------

; ------------ set defaults (allow scalar or array) -------------
if n_elements(start_position) eq 0 then start_position=0      ;def= first char
if n_elements(exlength) eq 0 then exlength=strlen(inarray)    ;def= length
if n_elements(start_position) ne narr then start_position= $  ;scalar->arr
    replicate(start_position(0),narr)
if n_elements(exlength) ne narr then exlength= $              ;scalar->arr
    replicate(exlength(0),narr)

start_position=start_position > 0                             ; allow -1
exlength=exlength > 0                                         ; allow -1
outarray=strarr(narr)                                         ; output array
; --------------------------------------------

; --- only loop for uniq combinations of start/length ----
uarr=long(start_position)*1024+exlength
upos=uniq(uarr,sort(uarr))

for i=0,n_elements(upos)-1 do begin
   s0=start_position(upos(i)) & l0=exlength(upos(i))     ; THIS combination
   which =where(start_position eq s0 and exlength eq l0) ; combo matches  
   outarray(which) = strmid(inarray(which),s0,l0)        ; vector operation
endfor

return,outarray
end
