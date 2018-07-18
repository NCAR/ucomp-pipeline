;+
; Project     : SOHO - CDS     
;                   
; Name        : PR_SYNTAX
;               
; Purpose     : print syntax of calling procedure/function
;               
; Category    : utility
;               
; Syntax      : IDL> pr_syntax,input
;
; Inputs      : INPUT = input syntax string
;               ERR_MESSAGE = error string to pass to caller
;               
; Keywords    : ERR = error message passed back to caller
;
; History     : 4-Sep-1997, Zarro (SAC/GSFC) - written
;               27-Sep-2016, Zarro (ADNET) - added ERR
;
; Contact     : dzarro@solar.stanford.edu
;-            

pro pr_syntax,input,err_message,err=err

err=''
if is_string(input) then begin
 caller=get_caller()
 print,'% '+caller+': syntax --> '+input
 if is_string(err_message) then err=err_message
endif

return & end

