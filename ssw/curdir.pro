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
;-
cd, current=current
return,current			; tough one
end
