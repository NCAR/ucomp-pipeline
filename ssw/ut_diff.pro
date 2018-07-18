;+
; Project     : HESSI     
;                   
; Name        : UT_DIFF
;               
; Purpose     : compute difference between local and UT time
;               
; Category    : time utility
;               
; Syntax      : IDL> print,ut_diff()
;
; Inputs      : None
;               
; Outputs     : hours difference between local and UT time
;               
; Keywords    : SECONDS = output in seconds
;               
; History     : 11-Nov-2002, Zarro (EER/GSFC)- Written
;               18-Nov-2014, Zarro (ADNET) - Modified to use ANYTIM
;     
; Contact     : dzarro@solar.stanford.edu
;-

function ut_diff,seconds=seconds

;-- compute hours difference between local and UT. If negative, we must be
;   east of Greenwich

diff=anytim(systim())-anytim(systim(/utc))

if ~keyword_set(seconds) then diff=diff/3600.

return, diff
end
