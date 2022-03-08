function ex2week, tim_in, year, wid=wid, get_uniq=get_uniq, qdebug=qdebug
;
;+
;Name:
;	ex2week
;Purpose:
;       To convert from any standard times to a week number.
;Method:
;       The definition of week starts on a Sunday, and the
;       first week of the year is = 1.  For the first
;       week, there can be less than 7 days in the week
;       The number of weeks in a year is 53 because
;       of the way the first and last weeks are counted.
;Input:
;       timarr  - Standard "ex" time array
;                 (HH,MM,SS,MSEC,DD,MM,YY)
;                 year is assumed to be of the form 91,
;                 not 1991.
;OPTIONAL KEYWORD INPUT:
;	wid	- If set, then return the string variable for
;		  the week ID for each input time.
;	get_uniq- If set, then return all of the uniq week
;		  numbers.
;Output:
;       returns week number
;	year	- the year number
;HISTORY:
;	Written Oct-91 by M.Morrison
;	17-May-93 (MDM) - Modified to allow any time formats in
;			- Added /WID and /GET_UNIQ option
;			- Corrected the handling of vector inputs
;-
;
daytim = anytim2ints(tim_in)
day = daytim.day
n = n_elements(day)
;
week = intarr(n)
year = intarr(n)
;
for i=0,n-1 do begin
    int2ex, 0, day(i), timarr				;to find out the year
    year(i) = timarr(6)
    ;
    ex2int, [0,0,0,0, 1,1, year(i)], dummy, day0        ;days since 1979 for 1-Jan of given year
    dow = ex2dow( [0,0,0,0, 1,1, year(i)] )		;day of week for 1-Jan of the given year
    ;
    week(i) = (day(i)-day0+dow)/7 + 1
end
;
if (keyword_set(wid)) then begin
    out = strarr(n)
    for i=0,n_elements(week)-1 do out(i) = string(year(i), format="(i2.2)") + '_' + string(week(i), format="(i2.2)")
end else begin
    out = week
end
;
if (keyword_set(get_uniq) and (n gt 1)) then begin
    v = year*100L + week
    ss = uniq(v, sort(v))
    out = out(ss)
    year = year(ss)
end
;
if (n_elements(out) eq 1) then begin
    out = out(0)
    year = year(0)
end
;
if (keyword_set(qdebug)) then stop
return, out
end
