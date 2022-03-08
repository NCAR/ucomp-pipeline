pro check_time, msod, ds79
;
;+
;Name:
;	check_check_time
;Purpose:
;	check to see that msod is within the range
;	0 to 86400000
;Input:
;	msod
;	ds79
;Output:
;	msod
;	ds79
;History
;	Written Fall '91 by M.Morrison
;	27-Jul-92 (MDM) Modified to make "i" a long word
;	24-Mar-93 (MDM) - Modified logic - see below
;	27-May-93 (MDM) - Changed the algorithm to be mathematical
;			  instead of a repeat loop
;	 3-Jan-95 (MDM) - Changed to use DOUBLE instead of FLOAT
;			  because when using a reference time of
;			  1-Jan-79, the resolution/accuracy for dates
;			  in 1994 is less than 20 seconds!!
;
;-
;
msinday = 86400000
n = n_elements(msod)
for i=0L,n-1 do begin
    case 1 of
	(msod(i) lt 0): begin
			    nday = long(msod(i)/msinday) - 1	;back up extra day since it is negative
								;nday is negative
			    ds79(i) = ds79(i) + nday
			    msod(i) = msod(i) - double(nday)*msinday	;should be positive now - MDM made double 3-Jan-95
			    if (msod(i) eq msinday) then begin & ds79(i) = ds79(i) + 1 & msod(i) = 0 & end	;special case
			end
	(msod(i) ge msinday): begin
			    nday = long(msod(i)/msinday)
			    ds79(i) = ds79(i) + nday
			    msod(i) = msod(i) - double(nday)*msinday	;MDM made double 3-Jan-95
			    msod(i) = long(msod(i)) mod msinday
			end
	else: ;do nothing
    endcase
end
;
end
