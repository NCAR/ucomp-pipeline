;+
;   Name: rem_elem2
;
;   Purpose: return subscripts of input array remaining after elements in
;	     a second array are removed
;
;   Input Parameters:
;      inarray - array to search/remove from
;      remarray - array of elements to search/remove from inarray
;
;   Output Parameters:
;      count - number of elements (subscripts) returned
;
;   Calling Sequence:
;      ss = rem_elem(inarray,remarray) ; subscripts remaining or -1
;
;   History: Written, 3-Feb-2007, R. Schwartz (CUA)
;		25-apr-2007, R Schwartz, value_locate(rm,inn) -> value_locate(rm,inn)>0
;		to protect against crash with scalar inn where all values gt rem
;-

function rem_elem2, inn, rem, count

count=0
if 1-exist(inn) then return,-1

count = n_elements(inn)
out   = count ge 2L^15 ? lindgen(count) : indgen(count)
if 1-exist(rem) then return,out

rm = get_uniq( rem )
ix  = n_elements(rm) gt 1 ? value_locate(rm, inn)>0: out  ;add >0 to protect against scalar -1
ix  = where( rm[ix] eq inn, nrx)
if nrx eq 0 then  return, out

if n_elements(ix) eq count then begin
 count = 0
 return, -1
endif

remove, ix, out
count = n_elements(out)
return, out
end

