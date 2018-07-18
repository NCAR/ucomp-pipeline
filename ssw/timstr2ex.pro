function timstr2ex, dattim_str, qtest=qtest, mdy=mdy, def_for=def_for
;
;+
;NAME:
;   timstr2ex
;PURPOSE:
;   Subroutine to convert a date/time string to a seven element array
;CALLING SEQUENCE:
;   tarr = timstr2ex('4-oct-91 15:22')
;   tarr = timstr2ex(!stime)
;INPUT:
;   dattim_str -  Character string
;           4-OCT-91  14:20
;           4-OCT-91 4:20:00
;           4-OCT-91 4:20:00.10
;           14:20:00 4-Oct-91
;           14:20:00 4-Oct-1991
;
;           92/12/25  OK (YY/MM/DD) **DEFAULT**
;           25/12/92  OK (DD/MM/YY)
;           12/25/92  NEED "MDY" SWITCH
;      If the year is missing, it will assume the current year
;      For 2 digit years, 00-49 are 2000-2049 and
;                50-99 are 1950-1999
;OPTIONAL KEYWORD INPUT:
;   mdy   - When using the "/" notation for the date, and having the
;       order MM/DD/YY, then it is necessary to use this switch.
;OUTPUT:
;       returns -       7 ELEMENT INTEGER*2 ARRAY CONTAINING, IN ORDER,
;                       HRS  MIN  SECS  MILLISECS  DAY  MON  YR ('90)
;ASSUMPTIONS:
;   Date is separated by - and comes before the month
;   No spaces before/after the -
;   Month is three letters
;   Time is separated by :
;   Number of characters for minutes is two
;   Number of characters for seconds is two
;   Fractions of seconds is designated by a decimal after the seconds
;   Need at least one space between date and time
;
;   For "/" notation for the date:
;     No spaces before/after the /
;     Assumes month is the middle number unless using the /mdy switch
;     Must include all three items (date, month, year)
;     Year must be the first or last item
;
;HISTORY:
;   Written Sep-91 by M.Morrison
;   15-Nov-91 (MDM) - Modified to break the string into two parts
;        before tackling the decompression.  That fixed
;        some problems that were found.
;    7-Jun-92 (MDM) - Modified to accept an array of times
;    4-Jan-93 (MDM) - Modified to accept the "/" notation for date
;    7-May-93 (MDM) - Modified the millisec extraction due to a
;        roundoff error(?)
;    6-May-98 (MDM) - Made the FOR loop long integer
;    7-Jan-00 (MDM) - Handled year "00"
;      - Made the default for ambiguous dates YY/MM/DD
;      - Modified year field to be 4 digit value (not 2)
;       10-jan-2000 - S.L.Freeland - added DEF_FOR keyword (backward compat..)
;       27-mar-2003 - A. Csillaghy - changed calculation of ms for idl 5.6
;       03-jun-2003 - T. Metcalf - Made msec calculation use long integer.
;       11-July-2004 - Zarro - added check for when full month name (e.g. JULY) entered
;    13-sep-2004, richard.schwartz@gsfc.nasa.gov changed FIX() to ROUND() in
;     extracting the milliseconds from the input string
;	 9-mar-2006, richard.schwartz@gsfc.nasa.gov, fixed bug using /mdy after 2000 (Y2K bug!!)
;
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
for j=0L,nn-1 do begin
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
    if (n_elements(temp) eq 1) then temp = [temp, ' ']  ;only one item was passed
    if (n_elements(temp) eq 3) then begin   ;possible that they used a notation like 25/ 1/92
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
    if ((p1 ne -1) or (p2 ne -1)) then begin       ;found the date part
    temp_date = temp(0)
    temp_time = temp(1)
    end else begin
    temp_date = temp(1)
    temp_time = temp(0)
    end
    ;
    p = strpos(temp_date, '-')
    if (p eq -1) then begin
    p = strpos(temp_date, '/')     ;slash notation added 4-Jan-93
    if (p ne -1) then begin
        temp = str2arr(temp_date, delim = '/')
        itemp = fix(temp)
        date = fix(temp(0))
        if (itemp(2) eq 0) or (itemp(2) gt 31) then begin
       ;DD/MM/YY
       year = temp(2)
       idate = 0
        end else begin
       ;YY/MM/DD
       year = temp(0)      ;DEFAULT
       idate = 2
        end
        if ( (not keyword_set(mdy)) and (temp(1) gt 12) ) then begin
       message, 'Default date notation should be DD/MM/YY or YY/MM/DD', /info
       message, 'Your input month is greater than 12.  Switching using /MDY option', /info
        end
        if ( (keyword_set(mdy)) or (temp(1) gt 12)) then begin
       if keyword_set(mdy) then begin
       		date = temp(1) & month=temp(0) & year= temp(2)
       endif else begin
       		date = temp(1)
       		month = temp(idate)
       		endelse
        end else begin
       date = temp(idate)       ;default
       month = temp(1)
        end
        if (month gt 12) then month = 0
    end else begin
        ;;print, 'TIMSTR2EX: No date included in the string.  Input = ', dattim_str0
    end
    end else begin
    temp = str2arr(temp_date, delim = '-')
    date = fix(temp(0))

    for i=0,11 do if (strmid(strupcase(temp(1)),0,3) eq months(i)) then month=i+1

    if (n_elements(temp) gt 2) then begin
        year = fix(temp(2))
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

;   ;if (n eq 3) then daytim(3) = (float(temp(2)) - fix(temp(2)) )*1000
;   ;if (n eq 3) then daytim(3) = float(temp(2))*1000. - long(temp(2))*1000l ;Dave Pike fix
;   ; andre csillaghy fix: the line above returned -32768 in daytim[3] on idl 5.6-linux
;   if (n eq 3) then daytim[3] = fix(float(temp[2])*1000. - fix(temp[2])*1000.)
; ras gives this better solution
;
;13-sep-2004, ras, fix()  changed to round() to prevent
;dropping round off bits. e.g. 19.571 is really 19.570999 and truncating
;using fix lops off .999 from the milliseconds and gets expressed as 570 milliseconds
;instead of 571 milliseconds
        if (n eq 3) then daytim[3] = round((float(temp[2]) - daytim[2])*1000.)
    end
    ;
    if (keyword_set(qtest)) then print, dattim_str0
    out(0,j) = daytim
end

;--- MDM added 7-Jan-00 making 4 digit year
ss = where( (out(6,*) ge 0) and (out(6,*) le 49), nss)
if (nss ne 0) then out(6,ss) = out(6,ss) + 2000
ss = where( (out(6,*) ge 50) and (out(6,*) le 99), nss)
if (nss ne 0) then out(6,ss) = out(6,ss) + 1900

if (nn eq 1) then out = out(*,0)
return, out
end
