pro anytim2weeks, sttim, entim, weeks, years, nobackup=nobackup, string_out=string_out
;
;+
;NAME:
;	anytim2weeks
;PURPOSE:
;	Given a starting and ending time, return a vector
;	of week numbers and year numbers where the times fall
;INPUT:
;	sttim	- the start time in "any" format
;OPTIONAL INPUT:
;	entim	- if not defined, just return the week/year for
;		  the start time
;OUTPUT:
;	weeks	- the week number
;	years	- the year numbers
;OPTIONAL KEYWORD INPUT:
;	nobackup - If set, then do not back up a week if the start
;		   time is within 90 minutes of the first day of the week.
;	string	- If set, then return the answer in string format (WIDs)
;HISTORY:
;	Written Feb-92 by M.Morrison
;        8-Feb-92 (MDM) - Added code to back up a week if the start time
;                         is within 90 minutes of the first day of a week
;	29-Aug-94 (MDM) - Added /NOBACKUP option to NOT back up a week
;			  when start time is within 90 minutes of the first
;			  day of the week.
;	20-Sep-94 (MDM) - Added /STRING option
;-
;
tarr = anytim2ex(sttim)
weeks = ex2week(tarr)
years = tarr(6)
;
;--- MDM added code for the special case where the start time is within the first 90 minutes of Sunday (the data in file obs92_xx
;    could start up to 90 minutes into the first day, because of the way the data is blocked by orbit)
;    In that case, we need to back up one week and start with that file.  Also applies to 1-Jan (1+1 = 2)
st_dow = ex2dow(tarr)
dummy = anytim2ints(tarr)
if ( ((st_dow eq 0) or (tarr(4)+tarr(5) eq 2)) and (dummy.time/1000. le 100*60.) and (not keyword_set(nobackup)) ) then begin
    weeks = weeks - 1
    if (weeks lt 1) then begin
        weeks = 53
        years = years - 1
    end
end
;
if (n_elements(entim) ne 0) then begin		;case where end time is also given
    weeks1 = weeks
    years1 = years
    ;
    tarr2 = anytim2ex(entim)
    weeks2 = ex2week(tarr2)
    years2 = tarr2(6)
    nyr = years2-years1
    for iyr=years1,years2 do begin
	if (iyr eq years2) then iend = weeks2 else iend = 53
	n = iend-weeks1+1	;number of weeks covered in this year
	weeks0 = indgen(n) + weeks1
	years0 = intarr(n) + iyr
	weeks1 = 1				;for the next year, start at week # 1
	if (iyr eq years1) then begin
	    weeks = weeks0
	    years = years0
	end else begin
	    weeks = [weeks, weeks0]
	    years = [years, years0]
	end
    end
end
;
if (keyword_set(string_out)) then begin
    weeks = string(years, format='(i2.2)') + "_" + string(weeks, format='(i2.2)') 
end

end
