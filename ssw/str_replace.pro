function str_replace, source, insub, outsub
;
;+
;   Name: str_replace
;
;   Purpose: replace all occurences of a substring with a replacement 
;	     if no replacement string is specified, a NULL is inserted 
;
;   Input Parameters:
;      source - source string (vector ok) 
;      insub - target string for replace
;      outsub - replacement string - default is NULL String (per 2001 mod)
;               (pre 2001 default was a BLANK)
;
;   Calling Example:
;      new=str_replace(strings,'old','new') ; 
;      new=str_replace(strings,'asdfa,' ')  ; replace 'asdfa' with ' '
;      new=str_replace(strings,'x','')      ; remove 'x' (-> null)
;      new=str_replace(strings,'x')         ; same (default=NULL)
;
;   History: slf, 11/19/91
;            slf, 19-mar-93	; optimize case where insub and outsub
;				; are each 1 character in length
;	     mdm, 21-Jul-97	; patch to handle big arrays
;            fz,  12-May-98     ; change loop variable to long
;            Zarro (EITI/GSFC), 17-Mar-01, used STRPOS instead of WHERE
;            when checking for delimiters
;            26-Jul-2005 - S.L.Freeland - DOCUMENTATION ONLY
;                          changed Documented default delimiter from blank 
;                          to null since the CODE default was changed in 
;                          the 2001 modification
;            Zarro (L-3Com/GSFC), 23-Oct-05; protect against insub/outsub 
;                          coming in as vectors
;            Zarro (ADNET), 30-Jan-09; added additional checks for
;                           insub/outsub coming in as vectors
;            Zarro (ADNET), 11-June-10, increased string limit to 200000
;-
;

;-- check if insub is even present

s1=size(source)
s2=size(insub)
s3=size(outsub)
if (s1(n_elements(s1)-2) ne 7) then return,''
if (s2(n_elements(s2)-2) ne 7) then begin
 if n_elements(source) eq 1 then return,source[0] else return,source
endif

chk=where(strpos(source,insub[0]) gt -1,scount)
if scount eq 0 then begin
 if n_elements(source) eq 1 then return, source[0] else return,source
endif

;remove substrings is default

if (s3(n_elements(s3)-2) ne 7) then outsub=''

verbose=keyword_set(verbose)
if (keyword_set(source)) then if (total(strlen(source)) gt 200000l) then begin
    ;--- Following code needed because of "String too long: Concatenation (+)."
    ;    IDL errors when using big arrays.  Definitely breaks on 81956 characters.
    out = source
    for i=0L,n_elements(source)-1 do out[i] = str_replace(source[i], insub[0], outsub[0])
    return, out
end
;

tsource=source				;dont clobber input

; if insub and outsub are both 1 character length, then then a byte replace 
; can be done - slf, 19-mar-1993

;-- force insub/outsub to be scalars in case they come in as single
;   element vectors (DMZ)

if strlen(insub[0]) eq 1 and strlen(outsub[0]) eq 1 then begin
   bsource=byte(tsource)
   binsub=byte(insub[0])
   boutsub=byte(outsub[0])
   winsub=where(bsource eq binsub[0],icount)
   if icount gt 0 then bsource(winsub)=boutsub[0]
   newstring=string(bsource)      
endif else begin
   ; slf, find uniq 1 character delimiter (makes str2arr phase much faster)
   delim_list=['%','@','&','+','$','^','#']
   di=-1
   repeat begin
      di=di+1
      arr_delim=delim_list(di)
      chk=strpos(tsource,arr_delim)
      tdelim=where(chk gt -1,dcount)
   endrep until (dcount eq 0) or (di eq n_elements(delim_list)-1)
   if dcount ne 0 then arr_delim = '\\\\'	; last chance, hopefully uniq
   ssource=size(tsource)
   sarray=ssource[0] eq 1			;array operation
   if sarray then tsource=arr2str(tsource,delimit=arr_delim)
   split = str2arr(tsource, delimit=insub[0])	;make array via delimt insub
   newstring=arr2str(split,delimit=outsub[0])	;rebuild string via delimit out
   if sarray then newstring=str2arr(newstring,delimit=arr_delim)
endelse

return,newstring
end
