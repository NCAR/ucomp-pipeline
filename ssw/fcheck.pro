;+
; Project     : SDAC    
;                   
; Name        : FCHECK
;               
; Purpose     : This functions checks sets a non-existent variable
;		to its default values.
;               
; Category    : GEN
;               
; Explanation : The variable is checked to see if it is defined,
;		if it's not defined it is set to the given
;		default.  The ultimate default value is 0.
;               
; Use         : 
;    
; Inputs      : P1 - The variable to be checked for existence.
;		If P1 does not exist, then it is set to
;		to P2 or 0 if P2 does not exist.
;               
; Opt. Inputs : None
;               
; Outputs     : None
;
; Opt. Outputs: None
;               
; Keywords    : 
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: 
;               
; Side effects: None.
;               
; Prev. Hist  :
;		First written by RAS, 1987
;
; Modified    : 
;		Version 2, RAS, 16-Nov-1989
;		Version 3, RAS, 5-Feb-1997
;-            
;==============================================================================
function fcheck, p1, p2
on_error, 2
;
;if (n_elements(p2) ne 0) then if (p1 ne p2) then begin
;    print, 'FCHECK: p1 ne p2'
;    print, 'p1 = ', p1
;    print, 'p2 = ', p2
;end
;
out = 0
if (n_elements(p2) ne 0) then out = p2
if (n_elements(p1) ne 0) then out = p1
return, out
end
