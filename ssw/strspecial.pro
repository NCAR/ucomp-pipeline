function strspecial,  strarray,  digit=digit, alpha=alpha, $
   firstchar=firstchar, lastchar=lastchar, lchar=lchar, rv=rv
;+
;   Name: strspecial
;
;   Purpose: return true if input is a 'special' character (or as defined by keyword)
;
;   Input Parameters:
;      strarray - scaler string or string array 
;
;   Output
;      function returns truth value (VECTOR) , depending upon keyords set
;
;   Keyword Parameters:
;      lastchar (input)  switch, look at LAST character  (default is FIRST)
;      firstchar (input) switch, look at FIRST character (default for arrays)
;      digit -  (input)  switch, return TRUE where character in {0-9}
;      alpha -  (input)  switch, return TRUE where character in {a-z, A-Z} 
;      lchar -  (output) return LAST character array (last char in strarray)
;      chkall - (input)  strarray must be scaler - boolean for entire string
;
;   Calling Sequence:
;      truth=strspecial(arr)             ; =1 where leading chars are special
;      truth=strspecial(arr,/digit)      ; =1 where leading chars in {0-9}
;      truth=strspecial(arr,/alpha,/last); =1 where trailing chars in {a-z,A-Z} 
;      
;   Sample Calls:
;      A: Scaler input, no positional keywords (FIRSTCHAR & LASTCHAR)
;      IDL> print,strspecial('*-TITLE-*')	    ; boolean for each character
;           1 1 0 0 0 0 0 
;      B: Scaler input w/ positional keyword	
;      IDL> print,strspecial('abcd1',/last,/digit)  ; only first or last
;           1
;      C: Array input (default looks at FIRSTCHAR of each element)
;      IDL> print,strspecial(['abc','123','!@#'],/lastchar)
;           0       0       1 
;   History:
;      15-jul-1995
;      28-jul-1995 - add DIGIT, ALPHA, LASCHAR keywords
;       2-aug-1995 - added recursive segment for all characters of scaler
;
;   Restrictions:
;      just looks at FIRST or LAST characters if input is an ARRAY
;      trailing blanks are not "special" 
;
;   Method: recursive for scaler strings
;-
; ------------------ input must be string -------------------
if not data_chk(strarray,/string) then begin
   message,/info,"Need string or string array input..."
   message,/info,"IDL> truth=strspecial(strarray [,/digit,/alpha,/lastchar])
   return,''
endif

lastchar=keyword_set(lastchar)
firstchar=keyword_set(firstchar)
chkall= n_elements(strarray) eq 1 and n_elements(rv) eq 0 and $
        ((1-firstchar) and (1-lastchar))

firstchar = (1-lastchar)			; make this the default

if chkall then begin				; recurse (call "old" code")
;  ----------------------------------------------------------------------
   if n_elements(rv) eq 0 then rv=[-1]
   for i=0,strlen(strarray(0))-1 do rv=[rv, strspecial( $
      strmid(strarray(0),i,100),first=firstchar,last=lastchar,$
      digit=digit, alpha=alpha, rv=rv)]
   retval=rv(1:*)
;  ----------------------------------------------------------------------
endif else begin
;  ----------------------------------------------------------------------
;  make character array for use in comparsions
   fchar=strupcase(strmid(strarray,0,1))		; first character
   lchar=strupcase(strlastchar(strarray))		; last character
   char=([[fchar],[lchar]])(*,keyword_set(lastchar)) 	; char array of interst

;  generate booleans
   specials =  strlowcase(char) eq char		; only a-z,A-Z effected
   digits   =  char ge '0' and char le '9'	; where digits
   alphas   =  1 - specials			; ALPHAS are NOT specials

   case 1 of 
      keyword_set(digit): retval=digits
      keyword_set(alpha): retval=alphas
      else:   retval=(specials and (1-digits))
   endcase
   retval = retval and strlen(char) ne 0	; dont judge null strings
;  ----------------------------------------------------------------------
endelse
   
return,retval
end
