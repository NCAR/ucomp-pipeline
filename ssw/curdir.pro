function curdir
;
;+
;   Name: curdir
;
;   Purpose: return current directory 
;
;   Output
;   History: 
;      slf, circa 1-Dec-1992
;      slf, 9-mar-1993		; use cd, not spawn
;      slf, 23-jan-1996         ; problem with UNIX 4.01 (which OS??)
;				;    use spawn for those...
;      slf,  7-nov-1996         ; force output->scalar ("cd" consistent)
;-
;                     
oslist=['ultrix']  	; [--- extend oslist (vector)  if required ---]

if is_member(!version.os,oslist) and since_version('4.0.1') then $
  spawn,'pwd',/noshell,current else cd, current=current

return,(current)(0)			; tough one
end
