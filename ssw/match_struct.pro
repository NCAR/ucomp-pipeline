;+
; Project     :	SDAC
;
; Name        :	MATCH_STRUCT
;
; Purpose     :	check if two structures are identical
;
; Explanation :	cross-checks type and value of each field
;
; Use         : STATUS=MATCH_STRUCT(STRUCT1,STRUCT2)
;
; Inputs      :	S1, S2 = input structures
;
; Opt. Inputs :	None.
;
; Outputs     :	STATUS = 1/0 is input structure are/are not identical
;
; Opt. Outputs:	None.
;
; Keywords    :	TAG_ONLY = set to check if only tags are the same
;               FLOATING = do checks in floating point
;               BLANK = treat string blanks as valid characters
;               TYPE_ONLY = set to check if datatype of each tag
;               is the same (values are not checked)
;               EXCLUDE = tags to exclude (e.g [1,3,4] or [tag1,tag2..])
;               INCLUDE = tags to include
;               SENSITIVE = make string matches case sensitive
;               DTAG = tag name where first difference is found
;
; Category    :	Structure handling
;
; Prev. Hist. :	None.
;
; Written     :	Dominic Zarro (ARC/GSFC)
;
; Modified    : To handle arrays of strings.  CDP, 27-Feb-95
;               Removed redundant string check. DMZ, 1-March-95
;               Fixed subtle array bug that lurked for 6 years 
;               (Zarro EITI,March 2001)
;
;-

function match_struct,s1,s2,tags_only=tags_only,floating=floating,blank=blank,$
               dtag=dtag,sensitive=sensitive,type_only=type_only,include=include,exclude=exclude

on_error,1

status=0b
dtag=''

if (datatype(s1) ne 'STC') or (datatype(s2) ne 'STC') then begin
 message,'syntax --> STATUS=MATCH_STRUCT(STRUCT1,STRUCT2)',/contin
 return,status
endif

;-- check that input structures have same number of tags

t1=tag_names(s1) & t2=tag_names(s2)
if n_elements(t1) ne n_elements(t2) then return,status
ntags=n_elements(t1)

match,t1,t2,a,b
if ((a(0) eq -1) or (b(0) eq -1)) or (n_elements(a) ne ntags) then return,status


if keyword_set(tags_only) then return,1b

;-- check if datatype match

if keyword_set(type_only) then begin
 return,match_struct(clear_struct(s1(0)),clear_struct(s2(0)),dtag=dtag)
endif

;-- flag tags to include/exclude

if exist(exclude) then begin
 if datatype(exclude) eq 'STR' then begin
  to_exclude=where_vector(trim(strupcase(exclude)),trim(t1),count) 
 endif else to_exclude=exclude
endif else to_exclude=-1

if exist(include) then begin
 if datatype(include) eq 'STR' then begin
  to_include=where_vector(trim(strupcase(include)),trim(t1),count) 
 endif else to_include=include
endif else to_include=indgen(ntags)

;-- check that everything matches

for i=0,n_elements(t1)-1 do begin

 check=where(i eq to_include,count)
 if count gt 0 then begin
  check=where(i eq to_exclude,count)
  if count eq 0 then begin

   dtag=t1(i)
   chk=where(dtag eq t2,dcount)

   if dcount gt 0 then begin
    for k=0,dcount-1 do begin
     j=chk(k)
     if t1(i) ne t2(j) then return,0b

     f1=s1.(i) & f2=s2.(j)

     sz1=size(f1) & sz2=size(f2)

     n1=n_elements(sz1) & n2=n_elements(sz2)

     if sz1(0) ne sz2(0) then return,0b

     if sz1(n1-2) ne sz2(n2-2) then return,0b

     if sz1(n1-1) ne sz2(n2-1) then return,0b


;-- have to do the following in case there are small differences
;  due to round-off

     dtype=datatype(f1)
     if (dtype ne 'STR') and (dtype ne 'STC') and keyword_set(floating) then begin
      f1=float(f1) & f2=float(f2)
     endif

     if (dtype eq 'STR') then begin
      if not keyword_set(blank) then begin
       f1=strtrim(f1,2) & f2=strtrim(f2,2)
      endif
      if not keyword_set(sensitive) then begin
       f1=strlowcase(f1) & f2=strlowcase(f2)
      endif
     endif

     case 1 of

;-- structure case

     datatype(f1) eq 'STC' : begin   
     status=match_struct(f1,f2,tags_only=tags_only,floating=floating,$
                         dtag=dtag,blank=blank)
     end

     else: begin
     clook=where( (f2 eq f1) eq 1b,cnt)
     status=(cnt eq n_elements(f1))
     end

     endcase
     if total(status) ne n_elements(status) then return,0b
    endfor
   endif
  endif
 endif
endfor

;-- made it this far, so must be ok

status=1b
dtag=''

return,status & end

