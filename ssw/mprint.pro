;+
; Project     : VSO
;
; Name        : MPRINT
;
; Purpose     : Print message. Similar to MESSAGE but without setting 
;               !error_state.msg or !err_string
;
; Category    : utility help
;
; Syntax      : IDL> mprint,mess
;
; Inputs      : MESS = string message to print.
;
; Outputs     : Terminal output
;
; Keywords    : INFORMATIONAL = if set, check !QUIET
;               DEBUG = if set, check $DEBUG
;               NONAME = set to not prefix name of calling routine
;               ALLOW_BLANK = set to allow printing blank strings
;
; History     : 19 February 2015, Zarro (ADNET)
;               19 April 2016, Zarro (ADNET) - added INFORMATIONAL
;               15 June 2016, Zarro (ADNET) - added DEBUG 
;               16 January 2019, Zarro (ADNET) - added ALLOW_BLANK
;
; Contact     : dzarro@solar.stanford.edu
;-

pro mprint,mess,_extra=extra,noname=noname,informational=informational,debug=debug,$
  allow_blank=allow_blank

blank=keyword_set(allow_blank)
if keyword_set(debug) && (getenv('DEBUG') eq '') then return
if keyword_set(informational) && (!quiet eq 1) then return

if ~blank && is_blank(mess) then return
np=n_elements(mess)
if keyword_set(noname) then prefix='% ' else begin
 caller=get_caller()
 prefix='% '+caller+': '
endelse
pad='%'+strpad('',strlen(prefix)-1)
k=-1
for i=0,np-1 do begin
 if ~blank && is_blank(mess[i]) then continue
 k=k+1
 if k eq 0 then print,prefix+mess[i] else print,pad+mess[i]
endfor
return & end


