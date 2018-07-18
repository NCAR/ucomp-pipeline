pro tbeep, nbeeps , ibwait , waitn=waitn
;
;+ 
;   Name: tbeep
;
;   Purpose: beep terminal
;
;   Input Paramters:
;      nbeeps - number of beeps (defalut=1)
;      ibwait - inter-beep wait
;
;   Keyword Parameters:
;      waitn  - inter-beep wait (can be positional too)
;
;   History - slf, 2-Sep-92 (couldnt rembember existing one)
;
;   Restrictions:
;      if ibwait is less then .15, not all beeps are visible
;
;-
if n_elements(ibwait) gt 0 then waitn=ibwait
if n_elements(waitn) eq 0 then waitn=.2 
if n_elements(nbeeps) eq 0 then nbeeps = 1
for i=0,nbeeps-1 do begin
   wait,waitn
   print,string(7b),format='(a,$)'
endfor
return
end
   
