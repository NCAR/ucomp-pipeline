function strrempat, inarray, pattern, remcount, $
	trunc=trunc, all=all, patss=patss
;
;+
;   Name: strrempat
;
;   Purpose: identify/remove 1st occurence of pattern in inarray 
;
;   Input Paramters:
;      inarray - string array 
;      pattern - pattern to remove 
;      remcount - number of elements in inarray where pattern was found
;
;   Keyword Parameters:
;      trunc - if set, truncation after pattern (not removal) is performed)
;      all   - if set, all occurences are removed (using str_replace)
;      patss    - returns subscripts of inarray where pattern matctched
;
;
;   Method: 1st occurence of pattern in inarray is found
;	    (since idl does not allow strmid with vector positions)
;	    this routine uses vector operations for simular pattern 
;	    positions for optimization instead of looping through each 
;	    element of inarray
;
;   History:
;      slf, 7-jan-1992
;
;   Category:
;      gen , util, string
;-

posfunc=['strpos','str_lastpos']		
posfunc=posfunc(keyword_set(trunc) and keyword_set(all))	
;
if keyword_set(all) and (1-keyword_set(trunc)) then $
   outarray=str_replace(inarray,pattern,'') else begin $
;
   outarray=[inarray]
   patlen=strlen(pattern)
   patpos=call_function(posfunc,inarray,pattern)
   endpat=patpos + patlen 
   patss=where(patpos + 1,remcount)
   uniqpos=0
   if n_elements(patpos) gt 1 then uniqpos=uniq(patpos,sort(patpos))

   for i = 0 , n_elements(uniqpos)-1 do begin
      if uniqpos(i) ne -1 then begin
         ss=where(patpos eq patpos(uniqpos(i)))

         if keyword_set(trunc) then $
            outarray(ss)=strmid(inarray(ss),endpat(uniqpos(i)),1000) $
         else outarray(ss) = $
               strmid( inarray(ss),0,patpos(uniqpos(i)) ) +	$
               strmid( inarray(ss),endpat(uniqpos(i)),1000 )
      endif
   endfor

endelse

return,outarray
end


