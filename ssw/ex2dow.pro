function ex2dow, timarr, str_dow
;
;+
;Name:
;	ex2dow
;Purpose:
;	To convert from the standard 7 element time array
;	(HH,MM,SS,MSEC,DD,MM,YY) to a day of week number
;	for that date.  (0=sunday, 1=monday,6=saturday).
;Input:
;	timarr	- Standard "ex" time array 
;		  (HH,MM,SS,MSEC,DD,MM,YY) 
;		  year is assumed to be of the form 91, 
;		  not 1991.
;Output:
;	day of week
;		0 = sunday
;		1 = monday
;	str_dow		= optional output, the day of week in
;			  a string.
;History:
;	Written 12-Oct-91 by M.Morrison
;-
;
;
str_dow_ref = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
;
iyr = timarr(6)
if (iyr gt 1900) then iyr = iyr-1900
;
;the day of week changes by one day each year.
;except for leap years which changes by two days
;year 1900 started with monday
; (mod(1900,4)=0 but 1900 was not a leap year ??????
iday0=1
for i=0,iyr-1 do begin      ;dont care about length of current year
    itemp = i
    if ((itemp mod 4) eq 0) then iday0=iday0+2
    if ((itemp mod 4) ne 0) then iday0=iday0+1
    if (i eq 0) then iday0=iday0-1  ;special case?!?!?!?!?!?
end
iday0 = iday0 mod 7
;
ex2int, [0,0,0,0, 1,1, iyr], dummy, day0        ;days since 1979 for 1-Jan of given year
ex2int, timarr, dummy, day
;
dow = (day-day0+iday0) mod 7
str_dow = str_dow_ref(dow)
;
return, dow
end
