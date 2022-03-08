
function weeks_in_year, input

;+
;NAME: 
;	weeks_in_year
;PURPOSE:
;	Return the weeks in the calendar year or years corresponding to
;	to an input time or times.
;INPUT:
;	input - may be:
;		 - scalar or vector of years in any numerical format
;		 - scalar or vector of times in any format
;HISTORY:
;	06-Mar-2001 - GLS
;       28-Dec-2002 - Zarro (EER/GSFC), changed SIZE to DATA_CHK for backwards
;                     compatibility
;-

case data_chk(input,/type) of
  7:	years = reform((anytim(input,/ext))(6,*))
  8:    years = reform((anytim(input,/ext))(6,*))
  else: years = fix(input)
endcase
nweeks = replicate(53,n_elements(years))
ss_54 = where( ((years mod 4) eq 0) and $
	       (utc2dow(anytim('1-jan-'+strtrim(years,2),/mjd)) eq 6),count )
if count ne 0 then nweeks(ss_54) = 54

; Stupid kluge to insure that if a scalar is input, a scalar is output:
if n_elements(nweeks) eq 1 then nweeks = nweeks(0)

return, nweeks
end
