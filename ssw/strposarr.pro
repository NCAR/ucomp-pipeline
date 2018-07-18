function strposarr, source, substring, lastpos=lastpos
;
;+ 
;   Name: strposarr
;
;   Purpose: find position of 1st or last occurence of substring in each element
;	     of a string array (extended array version of idl strpos)
;
;   Input Paramters:
;	source - string or string array to search
;	substring - substring to match 
;
;   Optional Keyword Paramters:
;       lastpos - if set, position of last occurence is returned
;		  (calls str_lastpos instead of strpos)
;
;   Ouptut Paramters:
;	function returns long array with each element = character postion
;	of first match; return element is -1 if no match 
;
;   History: slf, 24-July-1992O
;-
if n_elements(substring) ne 1 then $
   message,'substring must be scaler'
;
functions=['strpos','str_lastpos']
whichfunc=functions(keyword_set(lastpos))	; first or last

case n_elements(source) of
   1: outarr=call_function(whichfunc,source,substring)
   else: begin
	     outarr=[0]
             for i=0,n_elements(source)-1 do begin
                outarr= $
		   [outarr,call_function(whichfunc,source(i),substring)]
	     endfor
             outarr=outarr(1:*)
   endcase
endcase      
return,outarr
end
