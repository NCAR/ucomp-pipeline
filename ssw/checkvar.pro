;*******************************************************************************
;FILE NAME   : [richard.cygnus]CHECKVAR.PRO
;
;DATE CHANGED: 89/11/16
;+
;PURPOSE     : CHECKS TO SEE WHETHER VARIABLE IS DEFINED, IF NOT SET TO DEFAULT
;-           : DEFAULTS TO 0
;*******************************************************************************
pro checkvar,a,deflt,deflt2
!quiet=1
if n_params(0) lt 2 then deflt=0
ta=size(a)
ta2=size(deflt) ;does deflt exist? 
if ta(1) eq 0 then if ta2(1) gt 0 then a=deflt else a=deflt2
return 
end
