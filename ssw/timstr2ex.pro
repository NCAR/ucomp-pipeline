function timstr2ex, dattim_str, qtest=qtest, mdy=mdy
;
;+
;NAME:
;	timstr2ex
;PURPOSE:
;	Subroutine to convert a date/time string to a seven element array
;CALLING SEQUENCE:
;	tarr = timstr2ex('4-oct-91 15:22')
;	tarr = timstr2ex(!stime)
;INPUT:
;	dattim_str -	Character string 
;				 4-OCT-91  14:20
;				 4-OCT-91 4:20:00
;				 4-OCT-91 4:20:00.10
;				 14:20:00 4-Oct-91
;				 14:20:00 4-Oct-1991
;
;				 92/12/25	OK
;				 25/12/92	OK
;				 12/25/92	NEED "MDY" SWITCH
;			If the year is missing, it will assume the current year
;OPTIONAL KEYWORD INPUT:
;	mdy	- When using the "/" notation for the date, and having the 
;		  order MM/DD/YY, then it is necessary to use this switch.
;OUTPUT:
;       returns	-       7 ELEMENT INTEGER*2 ARRAY CONTAINING, IN ORDER,
;                       HRS  MIN  SECS  MILLISECS  DAY  MON  YR ('90)
;ASSUMPTIONS:
;	Date is separated by - and comes before the month
;	No spaces before/after the -
;	Month is three letters
;	Time is separated by :
;	Number of characters for minutes is two
;	Number of characters for seconds is two
;	Fractions of seconds is designated by a decimal after the seconds
;	Need at least one space between date and time
;
;	For "/" notation for the date:
;		No spaces before/after the /
;		Assumes month is the middle number unless using the /mdy switch
;		Must include all three items (date, month, year)
;		Year must be the first or last item
;
;HISTORY:
;	Written Sep-91 by M.Morrison
;	15-Nov-91 (MDM) - Modified to break the string into two parts 
;			  before tackling the decompression.  That fixed
;			  some problems that were found.
;	 7-Jun-92 (MDM) - Modified to accept an array of times
;	 4-Jan-93 (MDM) - Modified to accept the "/" notation for date
;	 7-May-93 (MDM) - Modified the millisec extraction due to a
;			  roundoff error(?)
;-
;
months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', $
			'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
;
;------------------------------------------------------------------------
;
nn = n_elements(dattim_str)
out = intarr(7,nn)
;
daytim = intarr(7)
;
for j=0,nn-1 do begin
    dattim_str0 = dattim_str(j)

    year = 0
    month = 0
    date = 0
    hour = 0
    minute = 0
    sec = 0
    msec = 0
    ;
    temp = str2arr(strcompress(strtrim(dattim_str0,2)), delim=' ') ;break the input into two parts - better only be one or two parts
    if (n_elements(temp) eq 1) then temp = [temp, ' ']	;only one item was passed
    if (n_elements(temp) eq 3) then begin	;possible that they used a notation like 25/ 1/92
	pp = strpos(temp, '/')
	ss = where(pp ne -1)
	if (n_elements(ss) ge 2) then begin
	    date_save = arr2str(temp(ss), delim='')
	    ss = where(pp eq -1)
	    temp = [temp(ss), date_save]
	end
    end
    p1 = strpos(temp(0), '-')
    p2 = strpos(temp(0), '/')
    if ((p1 ne -1) or (p2 ne -1)) then begin		;found the date part
	temp_date = temp(0)
	temp_time = temp(1)
    end else begin
	temp_date = temp(1)
	temp_time = temp(0)
    end
    ;
    p = strpos(temp_date, '-')
    if (p eq -1) then begin
	p = strpos(temp_date, '/')		;slash notation added 4-Jan-93
	if (p ne -1) then begin
	    temp = str2arr(temp_date, delim = '/')
	    date = fix(temp(0))
	    if (temp(0) ge 32) then begin
		year = temp(0) 
		idate = 2
	    end else begin
		year = temp(2)		;default
		idate = 0
	    end
	    if ( (not keyword_set(mdy)) and (temp(1) gt 12) ) then begin
		message, 'Default date notation should be DD/MM/YY or YY/MM/DD', /info
		message, 'Your input month is greater than 12.  Switching using /MDY option', /info
	    end
	    if ( (keyword_set(mdy)) or (temp(1) gt 12)) then begin
		date = temp(1)
		month = temp(idate)
	    end else begin
		date = temp(idate)		;default
		month = temp(1)
	    end
	    if (month gt 12) then month = 0
	end else begin
	    ;;print, 'TIMSTR2EX: No date included in the string.  Input = ', dattim_str0
	end
    end else begin
	temp = str2arr(temp_date, delim = '-')
	date = fix(temp(0))

	for i=0,11 do if (strupcase(temp(1)) eq months(i)) then month=i+1

	if (n_elements(temp) gt 2) then begin
	    year = fix(temp(2))
	    if (year gt 1900) then year = year - 1900
	end else begin
	    tarr = timstr2ex(!stime)
	    year = tarr(6)
	end
    end
    ;
    daytim(4) = date
    daytim(5) = month
    daytim(6) = year
    ;
    p = strpos(temp_time, ':')
    if (p eq -1) then begin
	;;print, 'TIMSTR2EX: No time included in the string.  Input = ', dattim_str0
    end else begin
	temp = str2arr(temp_time, delim = ':')
	n = n_elements(temp)
	
	for i=0,n-1 do daytim(i) = fix(temp(i))

	;if (n eq 3) then daytim(3) = (float(temp(2)) - fix(temp(2)) )*1000
	if (n eq 3) then daytim(3) = float(temp(2))*1000. - fix(temp(2))*1000	;Dave Pike fix
    end
    ;
    if (keyword_set(qtest)) then print, dattim_str0
    out(0,j) = daytim
end

if (nn eq 1) then out = out(*,0)
return, out
end
