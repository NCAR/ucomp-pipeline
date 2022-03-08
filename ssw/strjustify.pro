function strjustify,inarray, left=left, right=right, center=center, $
	width=width, pad=pad, boxtext=boxtext
;+
;   Name: strjustify
;
;   Purpose: left/right justify or center string array 
;
;   Input Parameters:
;      inarry - string array input
;      
;   Output:
;      return value is justified or centered version of inarry (padded)
;
;   Keyword Parameters:
;      left - switch, if set, left justify
;      right - switch, if set, right justify
;      center - switch, if set, center 
;      width - strlen of returned array (default is max(strlen(inarrary))
;      pad - pad character (default is blank)
;      boxtext = boxtext
;
;   Calling Sequence:
;      justtext=strjustify(text [,/left, /right, /center, /box, width=width]
;   History:
;      16-May-1994 (SLF) Written
;       1-oct-1994 (SLF) add BOXTEXT keyword and fuction
;      14-apr-1995 (SLF) protect against scaler input
;      10-apr-1997 (SLF) protect against all null string input
;      
;-
;
length=strlen(inarray)
if not keyword_set(width) then width = max(length)>1

nblanks=width - length+1 
if keyword_set(center) then nblanks=(nblanks+1)/2

blanks=strarr(n_elements(inarray))

retval=bytarr(width,n_elements(inarray))
retval(*)=32b
retval=string(retval)

; only loop for uniq lengths
ulen=uniq(length,sort([length]))
; 
for i=0,n_elements(ulen)-1 do begin
   ss=where(length eq length(ulen(i)))	; always at least one, right
   blanks(ss)=string(replicate(32b,nblanks(ss(0))>1))
endfor


blanks=strmid(blanks,1,max(strlen(blanks)))

left=keyword_set(left) 
right=keyword_set(right)
center=keyword_set(center)

left = left or ( (1-right) and (1-center) )

case 1 of 
   left: retval = inarray + blanks
   right: retval = blanks + inarray
   center: retval = blanks + inarray + blanks
   else: message,/info,"Unexpected keyword combination"
endcase

if keyword_set(boxtext) then begin
   vchar='-'
   schar='|'
   if data_chk(boxtext,/string) then vchar=boxtext
   blen=max(strlen(retval)) 
   retval=strmid(retval+" ",0,blen)
   vpad=" " + string(replicate(32b,blen+2))
   border=" " + string(replicate((byte(vchar))(0),blen+2))
   retval= schar + " " + retval + " " + schar
   retval=[border,retval, border]
endif

return,retval
end
