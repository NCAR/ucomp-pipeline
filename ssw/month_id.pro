
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
;	Months, a string array or scalar
;
; OUTPUTS:
;       none explicit, only through commons;
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
; MODIFICATION HISTORY:
;	03-May-93, RAS
;-


function month_id, month


;given the 3 letter month string (JAN, FEB,...)
;find the corresponding number of the month
;
;mid is the mapping between the month id (1-12) and the following function
mid=[12   ,2   ,0   ,0   ,0   ,0   ,0   ,0 ,0   ,0   ,0   ,0   ,0   ,1   $
	,0   ,0   ,0   ,8	,0   ,0   ,3   ,0   ,0   ,4 ,0   ,0  ,10 $
	,5   ,9  ,11   ,0 ,7   ,0   ,6]

nm = n_elements(month)
m = rebin((byte(strupcase(strmid(month(*),0,3)))-65)*3,1,nm)-9

return, fix(strmid(month,0,0)) + (mid(m))(*)
end
