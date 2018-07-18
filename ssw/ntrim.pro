;+
; Project     : SOHO - CDS     
;                   
; Name        : NTRIM()
;               
; Purpose     : Calls TRIM(BYTE2INT(NUMBER),...)
;               
; Explanation : Avoids formatting BYTE variables as texts in TRIM().
;               
; Use         : PRINT,NTRIM(NUMBER)
;    
; Inputs      : NUMBER: Any variable that can be passed to TRIM
;               
; Opt. Inputs : FORMAT 
;               - Format specification for STRING function.  Must be a string
;		  variable, start with the "(" character, end with the ")"
;		  character, and be a valid FORTRAN format specification.  If
;		  NUMBER is complex, then FORMAT will be applied separately to
;		  the real and imaginary parts.
;
;               FLAG
;               - Flag passed to STRTRIM to control the type of trimming:
;
;			FLAG = 0	Trim trailing blanks.
;			FLAG = 1	Trim leading blanks.
;			FLAG = 2	Trim both leading and trailing blanks.
;
;		  The default value is 2.  If NUMBER is complex, then FORMAT
;		  will be applied separately to the real and imaginary parts.
;
; Outputs     : Returns TRIM(BYTE2INT(NUMBER),...)
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

FUNCTION NTRIM,NUMBER,FORMAT,FLAG
  
  IF N_PARAMS() EQ 0 THEN MESSAGE,"Use: RESULT = NTRIM(NUMBER)"
  
  CASE N_PARAMS() OF 
     1: RETURN,TRIM(BYTE2INT(NUMBER))
     2: RETURN,TRIM(BYTE2INT(NUMBER),FORMAT)
     3: RETURN,TRIM(BYTE2INT(NUMBER),FORMAT,FLAG)
  END
END
