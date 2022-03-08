;+
; PROJECT:
;       SOHO - CDS/SUMER
;
; NAME:
;       DPRINT
;
; PURPOSE: 
;       Diagnostic PRINT (activated only when DEBUG reaches DLEVEL)
;
; EXPLANATION:
;       This routine acts similarly to the PRINT command, except that
;       it is activated only when the environment variable DEBUG is
;       set to be equal to or greater than the debugging level set by
;       DLEVEL (default to 1).  It is useful for debugging.  
;
; CALLING SEQUENCE: 
;       DPRINT, v1 [,v2 ...] [,format=format] [,dlevel=dlevel]
;
; INPUTS:
;       V1, V2, ... - List of variables to be printed out.
;
; OPTIONAL INPUTS: 
;       None.
;
; OUTPUTS:
;       All input variables are printed out on the screen (or the
;       given unit)
;
; OPTIONAL OUTPUTS:
;       FORMAT - Output format to be used
;       UNIT   - Output unit through which the variables are printed. If 
;                missing, the standard output (i.e., your terminal) is used.
;
; KEYWORD PARAMETERS: 
;       DLEVEL - An integer indicating the debugging level; defaults to 1
;
; CALLS:
;       DATATYPE
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS: 
;       Can be activated only when the environment variable DEBUG (indicating 
;          the debugging level) is set to an integer which is equal to
;          or greater than DLEVEL
;       Can print out a maximum of 20 variables (depending on how many
;          is listed in the code)
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Utility, miscellaneous
;
; PREVIOUS HISTORY:
;       Written March 18, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, Liyun Wang, GSFC/ARC, March 18, 1995
;       Version 2, Zarro, SM&A, 30 November 1998 - added error checking
;       Version 3, Zarro, (EIT/GSFC), 23 Aug 2000 - removed DATATYPE calls
;
;-
;

PRO DPRINT,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,$
           v18,v19,v20,format=format,unit=unit,dlevel=dlevel,_extra=extra

   ON_ERROR, 2
   ON_IOERROR, io_error
   debug = FIX(getenv('DEBUG'))
   IF N_ELEMENTS(dlevel) EQ 0 THEN dlevel = 1
   IF dlevel GT debug THEN RETURN
   np = N_PARAMS()
   if np eq 0 then return
   s=size(unit)
   dtype= s(n_elements(s)-2)
   if dtype eq 2 THEN cmd = 'PRINTF,unit' ELSE cmd = 'PRINT'
   ok = 0
   FOR i = 1, np DO begin
    istr=strtrim(i,2)
    ok=0b
    check='ok = n_elements(v'+istr+') ne 0'
    stat=execute(check)
    if stat and ok then cmd = cmd+',v'+istr
   endfor
   s=size(format)
   dtype= s(n_elements(s)-2)

   IF dtype EQ 7 THEN cmd = cmd+',format='+format
   status = EXECUTE(cmd)

io_error:
;---------------------------------------------------------------------------
;  If the conversion fails, it means that either DEBUG is not set, or
;  set to something else that cannot be converted to integer
;---------------------------------------------------------------------------
   RETURN
END

;---------------------------------------------------------------------------
; End of 'dprint.pro'.
;---------------------------------------------------------------------------
