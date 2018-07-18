function ydb_exist, times, prefix, range=range, qdebug=qdebug
;+
;NAME:
;	ydb_exist
;PURPOSE:
;	Check if the needed YDB files are on-line (like PNT, ATR, ATT, ...)
;CALLING SEQUENCE:
;	ans = ydb_exist(index, 'PNT')
;	ans = ydb_exist(times, 'ATR')
;	ans = ydb_exist([sttim, entim], 'PNT', /range)
;INPUT:
;	times	- list of times in any of the 3 formats
;	prefix	- The prefix of the database files to be checked
;OPTIONAL KEYWORD INPUT:
;	range	- If set, then "times" is a two element array which
;		  is the start and stop time of the range needed.
;OUTPUT:
;	ans	- Boolean value.  If any of the needed files exist, 
;		  then returns a 1, otherwise it returns a 0
;HISTORY: 
;	Written 18-Aug-93 by M.Morrison (taking PNT_EXIST as start)
;	12-Oct-93 (MDM) - Added /RANGE option
;	13-Oct-93 (MDM) - Added capability of checking the range based on
;			  week/year number input
;			- Added /QDEBUG option
;	 2-Mar-94 (MDM) - Added strlowcase statement
;	16-Mar-94 (MDM) - Modified to check to see if the DIR_SXT_xxx
;			  environment variable exists before doing a FILE_EXIST
;       16-Feb-95 (RDB) - Changed file search to *.* - cause of VMS problem
;-

if (keyword_set(range)) then begin
    if (data_type(times) lt 6) then begin	;array is week/year numbers
	n = n_elements(times)
	wid = string(times(n/2:*), format='(i2.2)') + '_' + string(times(0:n/2-1), format='(i2.2)')
    end else begin
	if (n_elements(times) ne 2) then begin
	    print, 'YDB_EXIST: Improper use of /RANGE option.  TIMES must be'
	    print, 'two elements.  Start and end date/times.
	    return, 0
	end
	weeks = week_loop(times(0), times(1))
	wid = string(weeks.year, format='(i2.2)') + '_' + string(weeks.week, format='(i2.2)')
    end
end else begin
    tim2orbit, times, wid=wid
end
if (n_elements(wid) eq 1) then uwid = wid else uwid = wid(uniq(wid, sort(wid)))
files = strlowcase(prefix) + uwid + '*.*'
;
exist = file_exist( concat_dir('$DIR_GEN_'+strupcase(prefix), files))
if (max(exist) eq 0) then begin
    if (getenv('DIR_SXT_'+strupcase(prefix)) ne '') then begin
	exist = file_exist( concat_dir('$DIR_SXT_'+strupcase(prefix), files))		;didn't find anything, so check DIR_SXT_xxx
    end
end
;
if (keyword_set(qdebug)) then print, 'YDB_EXIST looking for ', files
return, max(exist)
end

