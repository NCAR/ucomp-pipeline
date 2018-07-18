pro str_checks, on=on, off=off, quiet=quiet, inquire=inquire
;+
;   Name: str_checks
;
;   Purpose: turn structure checks on or off (for make_str.pro)
;
;   Keyword Parameters:
;      on - if set, turns checking on  (more diagnostic messages but avoids
;					conflicts with idl save files)
;     off - if set, turns checking off (quieter but may conflict with
;					idl save files)
;
;   History:
;      slf, 3-feb-1993
;      slf, 4-feb-1993	; add diagnostics and quiet keyword
;      slf,26-mar-1993  ; document inquire keyword 
;
;   Calling Sequence:
;      str_checks  		; enable checks (and noisy messages)
;      str_checks,/on		; equivilent to above
;      str_checks,/off  	; disable checks 
;      str_checks,/inquire	; check flag state but dont change it
;
;   Common Blocks:
;      make_str_blk1
;
;   Restrictions: uses common block - should be handled by system variable 
;		  when system variable definitions are full integrated 
;
;
;-
common make_str_blk1, check_on
qtemp=!quiet
!quiet=keyword_set(quiet)
if not keyword_set(inquire) then check_on = 1-keyword_set(off) 
flag_state=['Disabled','Enabled']
if n_elements(check_on) gt 0 then state = flag_state(check_on) else $
   state='Undefined'
message,/info,'Structure Checks are ' + state
!quiet=qtemp
return
end
