;+
; Project     : SOHO - CDS
;
; Name        : GET_CALLER
;
; Purpose     : Get name of caller routine
;
; Category    : Utility
;
; Explanation : Uses HELP,CALLS=CALLS to get name of routine calling
;               current program.
;
; Syntax      : IDL> caller=get_caller(status)
;
; Inputs      : None.
;
; Opt. Inputs : None.
;
; Outputs     : CALLER = name of caller.
;
; Opt. Outputs: STATUS= 1 if one of the following conditions are met:
;               -- caller routine is XMANAGER
;               -- caller routine is calling itself recursively
;               -- caller routine is an event handler of itself
;               -- caller is blank
;
; Keywords    : PREV_CALLER = previous caller before caller
;                             (confusing isn't it?)
;
; Common      : None.
;
; Restrictions: None.
;
; Side effects: None.
;
; History     : Version 1,  20-Aug-1996,  D.M. Zarro.  Written
;               Version 2,  12-Jan-2011,  S.V.H. Haugan
;                 If no '<' found "calls", set var to proc/last_proc
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function get_caller,status,prev_caller=prev_caller

caller='' 
help,calls=calls
np=n_elements(calls)
status=0
prev_caller=''
last_caller=''
if np eq 0 then return,''

;for i=0,np-1 do dprint,i,' ',calls(i)

if np gt 2 then begin

;-- routine that called routine that called routine that called GET_CALLER

 if np gt 3 then begin
  proc=strupcase(calls(3))
  angle=strpos(proc,'<')
  if angle gt -1 then prev_caller=trim(strmid(proc,0,angle)) $
  ELSE                prev_caller=proc 
 endif

;-- routine that called routine that called GET_CALLER

 proc=strupcase(calls(2)) 
 angle=strpos(proc,'<')
 if angle gt -1 then caller=trim(strmid(proc,0,angle)) $
 ELSE                caller=proc

;-- called recursively?

 last_proc=calls(1)  ;-- routine that called GET_CALLER first

 angle=strpos(last_proc,'<')
 if angle gt -1 then last_caller=trim(strmid(last_proc,0,angle)) $
 ELSE                last_caller=last_proc
 
 status=last_caller eq caller
 if status then begin
  dprint,'% GET_CALLER: recursive'
  return,caller
 endif

;-- called from event handler?

 event=strpos(strupcase(caller),'_EVENT')
 if event gt -1 then begin
  caller_minus_event=strmid(caller,0,event)
  status=last_caller eq caller_minus_event
  if status then begin
   dprint,'% GET_CALLER: recursive from event handler' 
   return,caller
  endif
 endif

;-- called from XMANAGER

 status=caller eq 'XMANAGER' 
 if status then dprint,'% GET_CALLER: called from XMANAGER'

endif

caller=trim(caller)
status=caller eq ''
return,caller
end
