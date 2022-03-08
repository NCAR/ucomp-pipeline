FUNCTION CHKLOG,VAR,OS
;+
; Project     : SOHO - CDS
;
; Name        :
;	CHKLOG
; Purpose     :
;	Determine actual name of logical or environment variable.
; Explanation :
;	This routine determines the actual name of a logical name (VMS) or
;	environment variable (UNIX).  In VMS the routine TRNLOG,/FULL is used;
;	otherwise GETENV is used.
; Use         :
;	Result = CHKLOG( VAR  [, OS ] )
; Inputs      :
;	VAR = String containing the name of the variable to be translated.
; Opt. Inputs :
;	None.
; Outputs     :
;	The result of the function is the translated name, or (in VMS) an array
;	containing the translated names.
; Opt. Outputs:
;       OS = The name of the operating system, from !VERSION.OS.
; Keywords    :
;	None.
; Calls       :
;	None.
; Common      :
;	None.
; Restrictions:
;	None.
; Side effects:
;	None.
; Category    :
;	Utilities, Operating_system.
; Prev. Hist. :
;       Written  - DMZ (ARC) May 1991
;       Modified - DMZ (ARC) Nov 1992, to use GETENV
; Written     :
;	D. Zarro, GSFC/SDAC, May 1991.
; Modified    :
;	Version 1, William Thompson, GSFC, 23 April 1993.
;		Incorporated into CDS library.
;       Version 2, Dominic Zarro, GSFC, 1 August 1994.
;               Added capability for vector inputs
;       Version 3, Liyun Wang, GSFC/ARC, January 3, 1995
;               Added capability of interpreting the "~" character under UNIX
;
; VERSION:
;       Version 3, January 3, 1995
;-
;

   ON_ERROR,1
   IF N_ELEMENTS(var) EQ 0 THEN BEGIN
      MESSAGE,'invalid input',/contin
      RETURN,''
   ENDIF
   svar=var

   os=!version.os

   FOR i=0,N_ELEMENTS(svar)-1 DO BEGIN
      var=svar(i)
      IF os EQ 'vms' THEN BEGIN
         colon=STRPOS(var,':')
         IF colon EQ (STRLEN(var)-1) THEN $
            tvar=STRMID(var,0,STRLEN(var)-1) $
         ELSE tvar=var
         s=execute('v=trnlog(tvar,name,/full)')
         IF (v MOD 2) EQ 0 THEN name=''
      ENDIF ELSE BEGIN
         doll=STRPOS(var,'$')
         tilde = STRPOS(var,'~')
         ok = 0
         IF doll EQ 0 THEN tvar=STRMID(var,1,1000) ELSE BEGIN
            IF tilde EQ 0 THEN BEGIN
;---------------------------------------------------------------------------
;              IDL does not know how to interpret "~".
;---------------------------------------------------------------------------
               IF STRMID(var,1,1) EQ '/' THEN BEGIN
                  home = getenv('HOME')
                  name = home+STRMID(var,1,2000)
                  ok = 1
               ENDIF ELSE BEGIN
                  spawn, 'cd '+var+'>& /dev/null; pwd', out
                  IF out(0) NE '' THEN BEGIN
                     name = out(0)
                     ok = 1
                  ENDIF ELSE tvar = var
               ENDELSE
            ENDIF ELSE tvar=var
         ENDELSE
         IF ok EQ 0 THEN BEGIN
            slash=STRPOS(tvar,'/')
            IF slash EQ (STRLEN(tvar)-1) THEN $
               tvar=STRMID(tvar,0,STRLEN(tvar)-1)
            name=getenv(tvar)
         ENDIF
      ENDELSE
      IF i EQ 0 THEN rvar = name ELSE rvar = [rvar,name]
   ENDFOR
   IF N_ELEMENTS(rvar) EQ 1 THEN rvar = rvar(0)
   RETURN, rvar
END
