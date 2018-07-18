;+
; Project     : HESSI
;
; Name        : ERR_STATE
;
; Purpose     : return !error_state.msg or !err_string
;
; Category    : utility help
;
; Syntax      : IDL> print,err_state()
;
; Inputs      : None
;
; Outputs     : !error_state.msg (if supported), else !err_string
;
; Keywords    : None
;
; History     : Written 6 Jan 2003, D. Zarro (EER/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

function err_state

err=''
defsysv,'!error_state',exists=exists
if exists then begin
 s=execute('err=!error_state.msg')
 return,err
endif

defsysv,'!err_string',exists=exists
if exists then s=execute('err=!err_string')

return,err

end

