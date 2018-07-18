function is_member, elements, set, swap_os=swap_os, ignore_case=ignore_case, $
	wc=wc
;
;+
;   Name: is_member
;
;   Purpose: check set membership (element(s) IN set?), return boolean
;
;   Input Parameters:
;      elements - item(s) to check
;      set - array (set) to check  (use keyword if not specified)
;
;   Keyword_Parameters:
;      swap_os - return true if current OS requires byte swapping
;      wc - if set, just check for pattern match
;
;   Calling Sequence:
;      truth=is_member(element, set)	; user specified values
;      truth=is_member(/swap_os)	; built in tests via keywords
;
;   Calling Examples:
;      IF is_member(/swap_os) THEN  			; check current OS
;      IF is_member(name,['n1','n2','n3']) THEN		; is name in namelist?
;      IF is_member(pattern,'n1,n2,n3']) THEN           ; same as above
;      IF is_member(name,namelist,/ignore_case) THEN    ; case insensitive
;      IF is_member(pattern,list,/wc) THEN		; pattern match?
;
;   History:
;      11-Apr-1994 (SLF) [reduce duplicate code, self-documenting code]
;      25-oct-1994 (SLF) add WC keyword and function 
;	3-oct-1995 (SLF) add linux to sawap_os
;       1-nov-1996 (SLF) allow SET to be scaler string (comma delimited)
;      29-nov-2006 (SLF) return 'is_lendian()' in specific case of /SWAP_OS
;                        (restore single point maint and auto-extension)
;      26-Feb-2007 (Zarro/Bromund) - removed EXECUTE calls
;-

case 1 of
   keyword_set(swap_os): begin
      return,is_lendian()  ; S.L.Freeland - 29-nov-2006 ; !! EARLY EXIT
   endcase

   n_params() eq 2: begin
      if data_chk(set,/scalar,/string) then chk_set=strtrim(str2arr(set),2) $
         else chk_set=set
      chk_elements=elements
   endcase
   else: begin
      print,'Calling Sequence:'
      print,'   truth=is_member(element, set)'
      print,'   truth=is_member(/keyword)  ; keywords= /swap_os
      return,-1
   endcase
endcase

if data_chk(chk_elements,/string) or data_chk(chk_set,/string) then begin
   chk_set=string(chk_set)
   chk_elements=string(chk_elements)
   if keyword_set(ignore_case) then begin
      chk_set=strlowcase(chk_set)
      chk_elements=strlowcase(chk_elements)
   endif
endif

outarr=intarr(n_elements(chk_elements))

if keyword_set(wc) then chk_elements='*'+chk_elements+'*'

for i=0,n_elements(outarr)-1 do begin

   if keyword_set(wc) then begin
      ss=wc_where(chk_set, chk_elements(i),cnt)  ; check pattern
   endif else begin
      ss=where(chk_elements(i) eq chk_set, cnt)  ; default is eq
   endelse

   outarr(i)=cnt gt 0
endfor

if n_elements(outarr) eq 1 then outarr=outarr(0)	; make scaler

return,outarr

end
