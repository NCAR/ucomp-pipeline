function ex2fid, tarr, sec=sec
;
;+
;NAME:
;	ex2fid
;PURPOSE:
;	Given a 7-element time array, generate the fileID (YYMMDD.HHMM)
;	for that time.
;CALLING SEQUENCE:
;	fid = ex2fid(tarr)
;	fid = ex2fid(tarr, /sec)
;INPUT:
;	tarr
;OPTIONAL INPUT:
;	sec	- If present, return (YYMMDD.HHMMSS)
;HISTORY:
;	Written 11-Dec-91 by M.Morrison
;	14-Oct-92 (MDM) - Modified to accept an array of times
;-
;
n = n_elements(tarr)/7
out = strarr(n)
;
for i=0,n-1 do begin
    tarr0 = tarr(*,i)
    if (keyword_set(sec)) then begin
	out(i) = string(tarr0(6), tarr0(5), tarr0(4), '.', tarr0(0), tarr0(1), tarr0(2), FORMAT = '(3i2.2,a,3i2.2)')
    end else begin
	out(i) = string(tarr0(6), tarr0(5), tarr0(4), '.', tarr0(0), tarr0(1), FORMAT = '(3i2.2,a,2i2.2)')
    end
end
;
if (n eq 1) then out = out(0)	;make into a scalar
return, out
end
