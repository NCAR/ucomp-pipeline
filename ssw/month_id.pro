;+
;
; NAME: 	
;	Month_id
;
; PURPOSE: 
;	Return the month number (1-12) as a function of the 3 letter
;	Month string.
;
; CATEGORY: 
;	Time format manipulation.
;
; CALLING SEQUENCE:  
;	Numbers = Month_id( Months )
;
; CALLED BY: 
;	Utime
;
; INPUTS:  
;	Months, a string array or scalar, upper or lower case.
;	The standard 3-letter representation for the months
;	jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec
; OUTPUTS:
;       none explicit, only through commons;
; Optional OUTPUTS:
;       error - set if function doesn't return values between 1-12
;
; RESTRICTIONS:
;	Months must be given as strings with the first three letters spelled
;	explicitly, i.e. ['Jan','Feb',...].  
;
; PROCEDURE:
;	Converts months to uppercase and then 3 byte vectors.  Arithmetic
;	operations then return a unique number for each month which is
;	used as the index into an array to return the number, 1-12.  A
;	returned value of 0 indicates that the string was not a valid
;	input.  It is possible for for invalid strings to return a number
;	from 1-12.  Written to replace looping "where" statements.  Output
;	has the same dimensions as the input, scalar returned as scalar.
;
;For a function m defined below as
;
;function m, month                                                 
;	 nm=n_elements(month)                                              
; return, rebin((byte(strupcase(strmid(month(*),0,3)))-65)*3,1,nm)-9
; end
; The strings for each of the months have a unique numerical result.
; We use this algorithm to provide the mapping from these strings to
; the numerical representation of the months
;IDL> print,test
;jan feb mar apr may jun jul aug sep oct nov dec
;IDL> print,m(test)
;      14
;       2
;      21
;      24
;      28
;      34
;      32
;      18
;      29
;      27
;      40
;       1
; Warning -
;	While the transformation of each 3 letter string is unique, other Ascii 
;	combinations may also map into these positions.
; MODIFICATION HISTORY:
;	03-May-93, RAS
;	28-nov-94, ras, fixed error in translating November to number
;-


function month_id, month, error=error

on_error, 2
error = 1
;given the 3 letter month string (JAN, FEB,...)
;find the corresponding number of the month
;
;mid is the mapping between the month id (1-12) and the following function
mid=[0, 12   ,2   ,0   ,0   ,0   ,0   ,0   ,0 ,0   ,0   ,0   ,0   ,0   ,1   $
	,0   ,0   ,0   ,8	,0   ,0   ,3   ,0   ,0   ,4 ,0   ,0  ,10 $
	,5   ,9  ,0   ,0 ,7   ,0   ,6, 0, 0, 0, 0, 0, 11, 0]

nm = n_elements(month)
m = rebin((byte(strupcase(strmid(month(*),0,3)))-65)*3,1,nm)-8
werror = where(mid(m) eq 0, nerror)
if nerror ge 1 then begin
	message,'Error interpreting date: '+month(werror)
endif

error = 0
return, fix(strmid(month,0,0)) + (mid(m))(*)
end
