PRO parcheck,parameter,parnum,types,dimens,message,$
	result=result,noerror=noerror,maxval=maxval,minval=minval
;+
; Project     :	SOHO - CDS
;
; Name        :	
;	PARCHECK
; Purpose     :	
;	Routine to check user parameters to a procedure
; Explanation :	
;	Routine to check user parameters to a procedure
; Use         :	
;	parcheck, parameter, parnum, types, dimens, [ message ]
;
;	EXAMPLE:
;
;	IDL> parcheck, hdr, 2, 7, 1, 'FITS Image Header'
;
;	This example checks whether the parameter 'hdr' is of type string (=7)
;	and is a vector (1 dimension).   If either of these tests fail, a 
;	message will be printed
;		"Parameter 2 (FITS Image Header) is undefined"
;		"Valid dimensions are 1"
;		"Valid types are string"	
;
; Inputs      :	
; ###	progname  - scalar string name of calling procedure
;	parameter - parameter passed to the routine
;	parnum    - integer parameter number
;	types     - integer scalar or vector of valid types
;		 1 - byte        2 - integer  3 - int*4
;		 4 - real*4      5 - real*8   6 - complex
;		 7 - string      8 - structure
;	dimens   - integer scalar or vector giving number
;		      of allowed dimensions.
;
; Opt. Inputs :	
;	message - string message describing the parameter to be printed if an 
;		error is found
;
;
; Outputs     :	None.
;
; Opt. Outputs:	None.
;
; Keywords    :	RESULT: Receives the error messages (string array)
;                       if the keyword /NOERROR is set.
;               
;               NOERROR: Set to avoid error message (stopping)
;                 
;               MINVAL: Minimum value for the parameter. Checked
;                       agains MIN([parameter]).
;
;               MAXVAL: Maximum value for the parameter.
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	
;	If an error in the parameter is a message is printed
;	a RETALL issued
;
; Category    :	Utilities, Miscellaneous
;
; Prev. Hist. :	
;       Taken from ZPARCHECK:
;	version 1  D. Lindler  Dec. 86
;	documentation updated.  M. Greason, May 1990.
;       
;
; Written     :	D. Lindler, GSFC/HRS, December 1986
;
; Modified    :	Version 1 (ZPARCHECK), William Thompson, GSFC, 29 March 1994
;			Incorporated into CDS library
;               Version 2, Stein Vidar Haugan, UiO, October 1995
;
; Version     :	Version 2, 11-October-1995
;-
;
;----------------------------------------------------------
  
  help,calls=callers
  progname=(str_sep(callers(1),' '))(0)
  
  IF N_params() LT 4 THEN BEGIN
      message,$
         'Use: PARCHECK, parameter, parnum, types, dimens, [message ]
      RETURN
   EndIF
   
; get type and size of parameter
   
   s = Size(parameter)
   ndim = s(0)
   type = s(ndim+1)
   
; check if parameter defined.
   
   IF type EQ 0 THEN BEGIN
      err = ' is undefined.'
      GOTO, ABORT
   EndIF
   
; check for valid dimensions
   
   valid = WHERE( ndim EQ dimens, Nvalid)
   IF Nvalid LT 1 THEN BEGIN
      err = 'has wrong number of dimensions'
      GOTO, ABORT
   EndIF
   
; check for valid type
   
   valid = WHERE(type EQ types, Ngood)
   IF ngood LT 1 THEN BEGIN
      err = 'is an invalid data type'
      GOTO, ABORT
   EndIF
   
; check for range
   IF N_elements(maxval) GT 0 THEN BEGIN
      dummy = WHERE(parameter GT maxval,count)
      IF count GT 0 THEN BEGIN
         err = 'is larger than maximum ('+trim(maxval)+")"
         GOTO,ABORT
      EndIF
   EndIF
   
   IF N_elements(MINVAL) GT 0 THEN BEGIN
      dummy = WHERE(parameter LT minval,count)
      IF count GT 0 THEN BEGIN
         err = 'is smaller than minimum ('+trim(minval)+")"
         GOTO,ABORT
      EndIF
   EndIF
   
   result=''
   RETURN
   
; bad parameter
   
   ABORT:
   default,MESSAGE,''
   mess = MESSAGE
   
   IF mess NE '' AND parnum NE 0 THEN mess = ' ('+mess+') '
   
   IF parnum EQ 0 THEN result = 'Keyword ' $
   ELSE result='Parameter '+STRTRIM(parnum,2)
   
   result = [Result + mess + $
             ' of routine ' + STRUPCASE(progname) + ' ' + err]
   sdim = ' '
   FOR i = 0,N_elements(dimens)-1 DO BEGIN
      IF dimens(i) EQ 0 THEN sdim = sdim + 'scalar' $
      ELSE sdim = sdim + STRING(dimens(i),'(i3)')
   END
   result = [result,'Valid dimensions are:'+sdim]
   
   stype = ' '
   FOR i = 0, N_elements( types )-1 DO BEGIN
      CASE types(i) OF
         1: stype = stype + ' byte'
         2: stype = stype + ' integer'
         3: stype = stype + ' longword'
         4: stype = stype + ' real*4'
         5: stype = stype + ' real*8'
         6: stype = stype + ' complex'
         7: stype = stype + ' string'
         8: stype = stype + ' structure'
      EndCASE
   EndFOR
   
   result = [result,'Valid types are:' + stype]
   
   IF Keyword_SET(noerror) THEN RETURN
   PRINT,''                     ; Blank line
   FOR i=0,N_elements(result)-1 DO Print,result(i)
   MESSAGE,"Aborting"
   
END
