pro tim2orbit, tim_in, fid=fid, wid=wid, tim2fms=tim2fms, tim2night=tim2night, orbit=orbit, scday=scday, saa=saa, $
		fem=fem_data, qstop=qstop, qdebug=qdebug, print=print, nowid=nowid, simple=simple
;
;+
;NAME:
;	tim2orbit
;PURPOSE:
;	Given a time, find the orbit for which that time falls within.
;CALLING SEQUENCE:
;	tim2orbit, roadmap, fid=fid
;	tim2orbit, roadmap, wid=wid
;	tim2orbit, '1-apr-92 2:22', fid=fid, wid=wid, tim2fms=tim2fms, orbit=orbit
;	tim2orbit, index, fem=fem
;INPUT:
;	tim_in	- The reference time to search the orbit for.
;		  Form can be (1) structure with a .time and .day
;		  field, (2) the standard 7-element external representation
;		  or (3) a string of the format "hh:mm dd-mmm-yy"
;OPTIONAL KEYWORD INPUT:
;	print	- If set, print out a summary of the conditions to the screen
;	simple	- If set, just calculate the "tim2fms" and "tim2night"
;	nowid	- If set, calculate everything except the WID (takes a while)
;KEYWORD OUTPUT:
;	fid	- a string array with the file ID for the input times
;	wid	- a string array with the week ID for the input times
;	tim2fms	- a floating point array with the number of minutes from
;		  the first minute of sun (FMS) that the dataset exists for
;	tim2night- a floating point array with the number of minutes before
;		  S/C night starts
;	orbit	- an integer array with the orbit number (approximately the
;		  revolution number)
;	scday	- a boolean array set true if the input time happens during
;		  S/C day
;	saa	- a boolean array set true if the input time happens in the
;		  middle of a SAA passage.
;	fem	- The FEM structures for the time range covered by the input
;		  times (It is NOT the full FEM structure for the orbit for 
;		  EACH INPUT TIME as it was originally)
;HISTORY:
;	Written 25-May-92 by M.Morrison
;	30-May-92 (MDM) - Added "scday" and "saa"
;	 8-Jun-92 (MDM) - Added "print" option
;	 9-Jun-92 (MDM) - Added "tim2night" option
;	17-Jul-92 (MDM) - Corrected an error in weekID generation 
;			  (string formats)
;	19-Aug-92 (MDM) - Fixed a problem with WeekID generation.  IDL trunactes
;			  at 256 (or 128) lines when using command "string(array)"
;	15-Sep-92 (MDM) - Fixed problem with WeekID generation.  Since the user
;			  might only specify HH:MM, and the FEM resolution is 
;			  better than 1 second, the WeekID (and FileID for that
;			  matter) might be off.  The fix is to add 59 seconds to
;			  the input time when the seconds/milliseconds is zero.
;			  (User could ask for 1-SEP-91 03:03 (FID 910901.0303) and
;			  it would give FID 910901.0126 because the true orbit
;			  start time is 03:03:45).  The 59 seconds is only added
;			  if ALL input times have seconds and milliseconds = 0.
;	23-Feb-93 (MDM) - Added case where the information of the SAA time is in
;			  the prior orbit record.  For example:
;				   SSSSSSSS
;				NNNNNNNDDDDDDDD
;				        ^	- time of interest
;	 9-Apr-93 (MDM) - Changed call to RD_FEM to use /FULL_WEEKS
;	29-Apr-93 (MDM) - Modification to handle bad input times
;	24-May-93 (MDM) - Modified to make the for loop variable integer*4
;	20-Jun-93 (MDM) - Changed the definition of the FEM output.  It used to be
;			  a FEM structure for each input time, now it is only a
;			  single FEM structure for each orbit for the range of 
;			  input times.
;	20-Jul-93 (MDM) - Changed logic considerably (removed for loops) 
;			  which sped things up
;			- Added /SIMPLE and /NOWID options
;	18-Feb-94 (MDM) - Corrected header information
;-
;
daytim = anytim2ints(tim_in)
daytim.day = daytim.day > 4625	;MDM added 29-Apr-93	day 4625 = 1-Aug-91
daytim0 = daytim		;unaltered input
ref_tim = daytim(0)
n = n_elements(daytim)
ss = where( (daytim.time mod 60000L) eq 0, count)		;added 15-Sep-92
if (n_elements(daytim) eq count) then daytim = anytim2ints(daytim, off=59.999)	;add 59 seconds
;
daytim_sec = int2secarr(daytim, ref_tim)
dummy = min(daytim_sec, imin)		;find min/max since input might not be in time order
dummy = max(daytim_sec, imax)
sttim = daytim(imin)
entim = daytim(imax)
day = sttim.day
time = sttim.time
time = time - 2*60.*60.*1000	;back up 2 hours
check_time, time, day
sttim.day = day
sttim.time = time
rd_fem, sttim, entim, fem_data, /full_weeks
fem_sec = int2secarr(fem_data, ref_tim)
;
scday = bytarr(n)
saa = bytarr(n)
;
ss1 = tim2dset(fem_data, daytim, offset=offset)
ss = where(offset gt 0)
if (ss(0) ne -1) then ss1(ss) = (ss1(ss) - 1) > 0		;back up one dataset
;
tim2fms = int2secarr(daytim0, fem_data(ss1)) / 60.
tim2night = fem_data(ss1).night / 60. - tim2fms
ss = where(tim2night gt 0)
if (ss(0) ne -1) then scday(ss) = 1
;
if (keyword_set(simple)) then return		;want to avoid the calculations below for speed
;
saa_dur = fem_data(ss1).en_saa - fem_data(ss1).st_saa
saa_times = anytim2ints(fem_data(ss1), off=fem_data(ss1).st_saa)
saa_dt = int2secarr(daytim0, saa_times)
ss = where((saa_dt ge 0) and (saa_dt le saa_dur))
if (ss(0) ne -1) then saa(ss) = 1
;
;--- Check previous orbit since the SAA could start in previous orbit night, but the
;    time being checked is in a different orbit.
;
ss2 = (ss1-1) > 0	;back up one dataset
saa_dur = fem_data(ss2).en_saa - fem_data(ss2).st_saa
saa_times = anytim2ints(fem_data(ss2), off=fem_data(ss2).st_saa)
saa_dt = int2secarr(daytim0, saa_times)
ss = where((saa_dt ge 0) and (saa_dt le saa_dur))
if (ss(0) ne -1) then saa(ss) = 1
;
fid = string(fem_data(ss1).st$fileid)
orbit = fem_data(ss1).sc_rev
;
if (keyword_set(nowid)) then return
;
n = n_elements(daytim0)
wid = strarr(n)
for i=0L,n-1 do wid(i) = string(fem_data(ss1(i)).year, format="(i2.2)") + '_' + string(fem_data(ss1(i)).week, format="(i2.2)")
;
if (keyword_set(print)) then begin
    ref_scday = ['Night', 'Day  ']
    ref_saa   = ['   ', 'SAA']
    print, '     Input               S/C Day     Night in   FileID    WeekID  D/N    SAA?
    print, '   Date     Time        Time  Min Ago  (min)
           ; 6-JUN-92  17:24:30   16:45:29 39.02   10.11  920606.1645  92_23  Day    SAA
    for i=0L,n-1 do begin
	print, fmt_tim(daytim0(i)), gt_time(fem_data(ss1(i)), /str), tim2fms(i), tim2night(i), $
				fid(i), wid(i), ref_scday(scday(i)), ref_saa(saa(i)), $
				format = '(a, 3x, a, f6.2,2x,f6.2, 4(2x,a))'
    end
end
;
end

