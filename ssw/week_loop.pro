function week_loop, sttim, entim
;
;+
;NAME: 
;	week_loop
;PURPOSE:
;	Given a start and end time, return a structure listing the
;	year number and week number for all weeks between the times
;INPUT:
;	sttim	- start time in any format
;	entim	- end time in any format
;HISTORY:
;	Written 16-Apr-92 by M.Morrison
;	 8-Feb-92 (MDM) Added code to back up a week if the start time
;			is within 90 minutes of the first day of a week
;-
;
qdebug = 1
;
out0 = {week_loop_str, year: fix(0), week: fix(0)}
;
st_tarr = anytim2ex(sttim)
en_tarr = anytim2ex(entim)

st_year = st_tarr(6)
en_year = en_tarr(6)
st_week = ex2week(st_tarr)
en_week = ex2week(en_tarr)
;
;--- MDM added code for the special case where the start time is within the first 90 minutes of Sunday (the data in file obs92_xx
;    could start up to 90 minutes into the first day, because of the way the data is blocked by orbit)
;    In that case, we need to back up one week and start with that file.  Also applies to 1-Jan-xx (1+1 = 2)
st_dow = ex2dow(st_tarr)
dummy = anytim2ints(st_tarr)
if ( ((st_dow eq 0) or (st_tarr(4)+st_tarr(5) eq 2)) and (dummy.time/1000. le 100*60.)) then begin
    st_week = st_week - 1
    if (st_week lt 1) then begin
	st_week = 53
	st_year = st_year - 1
    end
end
;
en_week1 = 53
if (st_year eq en_year) then en_week1 = en_week
n = (en_week1 - st_week + 1)
out = replicate(out0, n)
out.year = st_year
if (n eq 1) then out.week = st_week else out.week = indgen(n) + st_week
;
for i=st_year+1, en_year-1 do begin
    out_tmp = replicate(out0, 53)
    out_tmp.year = i
    out_tmp.week = indgen(53)+1
    out = [out, out_tmp]
end
if (st_year ne en_year) then begin
    out_tmp = replicate(out0, en_week)
    out_tmp.year = en_year
    out_tmp.week = 1
    if (en_week ne 1) then out_tmp.week = indgen(en_week)+1
    out = [out, out_tmp]
end
;
return, out
end
