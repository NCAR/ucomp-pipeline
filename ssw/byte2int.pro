;+
; Project     : SOHO - CDS     
;                   
; Name        : BYTE2INT()
;               
; Purpose     : Convert byte(s) to integer(s), nothing else.
;               
; Explanation : IF DATATYPE(NUMBER) EQ 'BYT' THEN RETURN,FIX(NUMBER)
;               
; Use         : result = byte2int(number)
;    
; Inputs      : NUMBER: Any variable, scalar or array.
;               
; Opt. Inputs : None.
;               
; Outputs     : Returns FIX(NUMBER) for byte values, or else simply NUMBER
;               
; Opt. Outputs: None
;               
; Keywords    : None
;
; Calls       : None
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Utility
;               
; Prev. Hist. : None.
;
; Written     : Stein Vidar H. Haugan, UiO, 26-February-1996
;               
; Modified    : Never.
;
; Version     : 1, 26-February-1996
;-            

FUNCTION byte2int,number
  
  IF N_PARAMS() EQ 0 THEN MESSAGE,"Use: RESULT = BYTE2INT(NUMBER)"
  IF datatype(number) EQ 'BYT' THEN RETURN,FIX(number)
  RETURN,number
  
END
