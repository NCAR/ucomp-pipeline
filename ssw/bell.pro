;+
; Project     : SOHO - CDS     
;                   
; Name        : Bell
;               
; Purpose     : To ring the terminal bell a specified number of times.
;               
; Explanation : Prints ascii code for the terminal bell.
;               
; Use         : IDL> bell, n
;    
; Inputs      : n   -  number of bell rings required  
;               
; Opt. Inputs : As above
;               
; Outputs     : None
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : None
;               
; Restrictions: None
;               
; Side effects: Noise
;               
; Category    : Utilities, user
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL,  31 March 1993
;               
; Modified    : 
;
; Version     : Version 1
;-            
pro bell, n

if n_params() eq 0 then n = 1
for i = 1, n do begin
  print,string(7b), format='($,a)'
  wait, 0.25
endfor
 
return
end
