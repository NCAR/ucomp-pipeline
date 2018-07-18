;+
; Project     : SOHO - CDS
;
; Name        : WHERE_VECTOR
;
; Purpose     : WHERE function for vectors
;
; Category    : Utility
;
; Explanation :
;
; Syntax      : IDL> ok=where_vector(vector,array,count)
;
; Inputs      : VECTOR = vector with with search elements
;               ARRAY = array to search for each element
;
; Opt. Inputs : None
;
; Outputs     : OK = subscripts of elements in ARRAY that match elements in vector

; Opt. Outputs: COUNT = total # of matches found
;
; Keywords    : TRIM = trim inputs if string inputs
;               CASE = make case sensitive if string inputs 
;               REST = indicies in ARRAY that don't match VECTOR
;               RCOUNT = # of non-matching elements
;               NOSORT = skip sorting input search vector
;
; Common      : None
;
; Restrictions: None
;
; Side effects: None
;
; History     : Version 1,  25-Dec-1995,  D.M. Zarro.  Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-


function where_vector,vector,array,count,nosort=nosort,$
       trim_string=trim_string,case_sens=case_sens,rest=rest,rcount=rcount

if not exist(vector) or not exist(array) then return,-1
count=0
np=n_elements(array)
rcount=np
rest=lindgen(np)

;-- protect inputs and modify

trim_string=keyword_set(trim_string)
case_sens=keyword_set(case_sens)

svec=vector & sarr=array

if not keyword_set(nosort) then begin
 rs=uniq([svec],sort([svec]))
 svec=svec(rs) 
endif

if datatype(vector) eq 'STR' then begin
 if trim_string then svec=strtrim(svec,2)
 if not case_sens then svec=strupcase(svec)
endif
if datatype(array) eq 'STR' then begin
 if trim_string then sarr=strtrim(sarr,2)
 if not case_sens then sarr=strupcase(sarr)
endif

state=''
nvecs=n_elements(svec)
pieces=strarr(nvecs)
v=svec & s=sarr
for i=0,nvecs-1 do begin
 index=strtrim(string(i),2)
 pieces(i)='(v('+index+') eq s)'
 if i eq 0 then pieces(i)='clook=where('+pieces(i)
 if i eq (nvecs-1) then pieces(i)=pieces(i)+',count)'
 if (nvecs eq 1) or (i eq 0) then conn='' else conn=' or '
 state=state+conn+pieces(i)
endfor

status=execute(strcompress(strtrim(state,2)))

if count gt 0 then begin
 rest(clook)=-1
 rlook=where(rest gt -1,rcount)
 if rcount gt 0 then rest=rest(rlook) else rest=-1
endif

return,clook & end

