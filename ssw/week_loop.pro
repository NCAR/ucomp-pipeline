
function week_loop, sttim, entim, weekstr=weekstr, year4digit=year4digit

;+
;NAME: 
;	week_loop
;PURPOSE:
;	Given a start and end time, return a structure listing the
;	year number and week number for all weeks between the times
;INPUT:
;	sttim - start time in any format
;	entim - end time in any format
;KEYWORD PARAMETERS:
;	weekstr (output) - string of form YY_WW or YYYY_WW  
;	year4digit (switch) - if set, out.year and weekstr are 4 digit
;HISTORY:
;	Written 16-Apr-92 by M.Morrison
;	08-Feb-1992 (MDM) Added code to back up a week if the start time
;			  is within 90 minutes of the first day of a week
;       06-Apr-1999 (SLF) Made it Y2K able via /year4digit
;       		  Added WEEKSTR output
;       09-May-2000 (PGS) Standardized year format in four places.
;	06-Mar-2001 (GLS) Completely re-written with new logic.
;TODO:
;	- Check with Sam about whether Mon's logic could be improved
;	  to only include a previus week where actually necessary
;	  (now it ALWAYS adds a week at the beginning if the start
;	  time is within 100 minutes of the startof the week)
;	- Vectorize the for loop, if possible
;	- Make weeks_in_year work on times in any format and not only
;	  years
;	- Make year4digit the default, and use wid_vec as output string
;	  name (removing weekstr)?
;-

st_tarr = anytim(sttim,/ext)
en_tarr = anytim(entim,/ext)

st_year = st_tarr(6)
en_year = en_tarr(6)
st_week = ex2week(st_tarr)
en_week = ex2week(en_tarr)
st_wid = strtrim(st_year,2) + '_' + string(st_week,format='(i2.2)')
en_wid = strtrim(en_year,2) + '_' + string(en_week,format='(i2.2)')

; Create concatenated week id vector consisting of week ids for all
; weeks in the years between st_year and en_year, inclusive

for i=st_year,en_year do begin
  nweeks = (weeks_in_year(i))(0)
  if i eq st_year then $
    wid_vec = strtrim(i,2) + '_' + string(indgen(nweeks)+1,format='(i2.2)') else $
    wid_vec = [wid_vec,strtrim(i,2) + '_' + string(indgen(nweeks)+1,format='(i2.2)')]
endfor

ss_good = where((wid_vec ge st_wid) and (wid_vec le en_wid))
wid_vec = wid_vec(ss_good)

; The following code (MDM) is for the special case where the start time is
; within the first 100 minutes of Sunday (the data in file obs92_xx could
; start up to 90 minutes into the first day, because of the way the
; data is blocked by orbit).  In that case, we need to back up one week
; and start with that file.  Also applies to 1-Jan-xx (1+1 = 2).

st_dow = ex2dow(st_tarr)
if ( ((st_dow eq 0) or (st_tarr(4)+st_tarr(5) eq 2)) and $
     ((anytim(st_tarr,/ints)).time/1000. le 100*60.) ) then $
  dummy = week_loop(anytim(anytim(sttim)-100*60,/ext),entim, $
		    weekstr=wid_vec,/year4digit)

nwid = n_elements(wid_vec)
out0 = {week_year_struc, year: fix(0), week: fix(0)}
out = replicate(out0, nwid)

if keyword_set(year4digit) then begin
  out.year = fix(strmid(wid_vec,0,4))
  out.week = fix(strmid(wid_vec,5,2))
endif else begin
  out.year = fix(strmid(wid_vec,2,2))
  out.week = fix(strmid(wid_vec,5,2))
  wid_vec = strmid(wid_vec,2,5)
endelse
weekstr = wid_vec

return, out

end
