;+
; Project     : SOHO - CDS     
;                   
; Name        : TYP()
;               
; Purpose     : Translate keywords (/INT,/BYT etc) to IDL type numbers
;               
; Explanation : Returns an array with the IDL type numbers corresponding
;               to the keywords set. See e.g., MAKE_ARRAY(), DATATYPE, 
;               and SIZE() for further explanation.
;               
; Use         : T=TYP([/BYT,/INT,/LON,/NAT,/FLO,/DOU,/REA,/COM,/STR])
;    
; Inputs      : Keywords only.
;               
; Opt. Inputs : None.
;               
; Outputs     : Returns an array of TYPE NUMBERS.
;               
; Opt. Outputs: None.
;               
; Keywords    : BYTe
;               INTeger
;               LONg
;               NATural numbers -- BYTes/INTegers/LONgs
;               FLOat
;               DOUble
;               REAl numbers -- BYTes/INTegers/LONgs/FLOats/DOUbles
;               COMplex
;               STRing
;               STC = structure
;
; Calls       : None.
;
; Common      : None.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : Utilities, Misc.
;               
; Prev. Hist. : None.
;
; Written     : SVH Haugan, UiO, 18-October-1995
;               
; Modified    : Version 2, SVHH, 30 April 1996
;                          Added structure data type.
;
; Version     : 2, 30 April 1996
;-            

FUNCTION typ,BYT=BYT,INT=INT,LON=LON,NAT=NAT,FLO=FLO,DOU=DOU,REA=REA,$
             COM=COM,STR=STR,STC=STC
  
  IF KEYWORD_SET(NAT) THEN BEGIN
     BYT = 1
     INT = 1
     LON = 1
  END
  
  IF KEYWORD_SET(REA) THEN BEGIN
     BYT = 1
     INT = 1
     LON = 1
     FLO = 1
     DOU = 1
  ENDIF
  
  types = [-1]
  
  IF KEYWORD_SET(BYT) THEN types = [types,1]
  IF KEYWORD_SET(INT) THEN types = [types,2]
  IF KEYWORD_SET(LON) THEN types = [types,3]
  IF KEYWORD_SET(FLO) THEN types = [types,4]
  IF KEYWORD_SET(DOU) THEN types = [types,5]
  IF KEYWORD_SET(COM) THEN types = [types,6]
  IF KEYWORD_SET(STR) THEN types = [types,7]
  IF KEYWORD_SET(STC) THEN types = [types,8]
  
  IF N_ELEMENTS(types) EQ 1 THEN $
     MESSAGE,"At least one keyword must be set"
  
  RETURN,types(1:*)
END

