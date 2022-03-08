pro input, str, ans, default_in, min_range, max_range
;
;+
;NAME:
;	input
;PURPOSE:
;	Prompt the user for input and allow a default
;	answer.  If the user simply types <CR>, then
;	the default answer is used.  The procedure can
;	also check that the answer falls within a range
;	of values
;INPUT:
;	str	- A string containing the question/prompt
;		  This value can be a string array, but that
;		  is only to type several lines for the question.
;		  There is only one answer.
;OUTPUT:
;	ans	- The answer
;OPTIONAL INPUT:
;	default_in - The default answer
;	min_range - The smallest acceptable answer
;	max_range - The largest accesptable answer
;
;	NOTE:
;	   If output type is string, and there are 4 parameters, 
;	   then the output is converted to uppercase
;HISTORY:
;	Written 1988 by M.Morrison
;-
;
if (n_elements(default_in) eq 0) then default=0.0 $ ;default answer is REAL type
				else default=default_in
;
def='  [Default: '  +  strtrim(string(default),2)  +  ' ] '
fmt='$(3a)'
;
repeat begin
    n=n_elements(str) 
    if (n gt 1) then begin
	for i=0,n-2 do print,str(i)
	print, str(n-1), def, format='(2a,$)'
    end else begin
	print, str, def, format='(2a,$)'
    end
    ;
    ans=' '
    read, "", ans
    ;
    if (ans eq '') then ans=default 
    type_conv, ans, default, type
    if ((type eq 1) and (n_params(0) ge 4)) then ans=strupcase(ans)
    ;
    flag=1
    if ((n_params(0) ge 4) and (type ne 1)) $
			then if (ans lt min_range) then flag=0  ;no good
    if ((n_params(0) ge 5) and (type ne 1)) $
			then if (ans gt max_range) then flag=0  ;no good
    ;
    if (flag eq 0) then begin
	print,string(7b)
	print,'Value out of range'
	print,'Minimum is: ', strtrim(min_range, 2)
	print,'Maximum is: ', strtrim(max_range, 2)
    end
end until (flag eq 1)
;
return
end
