;+
; Project     : HESSI
;                  
; Name        : TRIM2
;               
; Purpose     : vectorized version of TRIM
;                             
; Category    : string utility
;               
; Syntax      : IDL> out=trim2(in,flag)
;
; Inputs      : IN = input string
;                                   
; Optional    : FLAG = 0,1,2 [def = 2] 
;
; Outputs     : OUT = output string
;                
; History     : Written, 24-July-2002, Zarro (LAC/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-    

function trim2,in,format,flag,_extra=extra

if n_elements(in) eq 0 then return,''
if n_elements(flag) eq 0 then flag=2
flag= 0 > flag < 2
if n_elements(in) eq 1 then return,strtrim(in(0),flag) else $
 return,strtrim(in,flag)

end
