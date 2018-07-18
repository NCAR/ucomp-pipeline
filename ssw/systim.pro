;+
; Project     : RHESSI
;
; Name        : SYSTIM
;
; Purpose     : Wrapper around IDL systime that returns more sensible
;               string times
;
; Category    : utility time
;
; Syntax      : IDL> time=systim()
;
; Inputs      : Same as SYSTIME
;
; Outputs     : Same as SYSTIME, except for the following difference:
;                IDL> print,systime()
;                  Sun Jan  1 12:42:03 2006
;                IDL> print,systim()
;                  1-Jan-2006 17:41:42.254
;
; Keywords    : Same as SYSTIME
;
; History     : 1-Jan-2006, Zarro (L-3Com/GSFC) - written
;               10-Jul-2013, Zarro (ADNET) 
;                - make string output compatible with anytim/anytim2utc
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function systim,arg1,arg2,_ref_extra=extra

;-- need the following case statement for backwards compatability

case n_params() of
1: s=systime(arg1,_extra=extra)
2: s=systime(arg1,arg2,_extra=extra)
else: s=systime(_extra=extra)
endcase

;-- if output time is a string, convert it to a more sensible format

if is_string(s) then begin
 a=str2arr(strcompress(s),delim=' ')
 s=a[2]+'-'+a[1]+'-'+a[4]+' '+a[3]
endif 

return,s

end

 







