;+
; Project     : SDAC    
;                   
; Name        : CHECKVAR
;               
; Purpose     : This procedure checks sets a non-existent variable
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
; Inputs      : A - The variable to be checked for existence.
;		If A does not exist, then it is set to
;		to Deflt or Deflt2 in turn.
;		Deflt - The first default, may be a variable.
;		Deflt2= The second default, may be a variable,
;		if not set then A is set to 0
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
;		Version 3, RAS, 5-Feb-1997, 2nd default is zero!
;-            
;==============================================================================
pro checkvar,a,deflt,deflt2

on_error, 2

if n_elements(a) eq 0 then $
	if n_elements(deflt) ne 0 then a=deflt else $
		if n_elements(deflt2) ne 0 then a=deflt2 else a=0
end
