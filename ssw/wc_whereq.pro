function wc_whereq, strarr, pattern, count, case_ignore=case_ignore
;
;+
; Name: wc_whereq
;
; Purpose: find strarry elements  matching pattern w/imbeded question marks
;   
; History:
;   30-jun-1995 (SLF) 
;-
;
; verify string length=pattern lenght
retval=where(strlen(strarr) eq strlen(pattern),count)

if retval(0) ne -1 then begin
   case_ignore=keyword_set(case_ignore)
   bpat=byte(pattern)				; byte version of pattern
   barr=byte(strarr)				; byte version of strarr
   ques=where(bpat eq 63b,nqcnt)		; question marks
   barr(ques,*)=63b
   tarr=string(barr)
   if case_ignore then begin
      tarr=strupcase(tarr)
      pattern=strupcase(pattern)
   endif
   retval=where(tarr eq pattern,count)
endif

return,retval
end
