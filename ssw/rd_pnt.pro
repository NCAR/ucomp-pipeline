pro rd_pnt, input1, input2, pnt_data, indir=indir, status=status, $
	nearest=nearest, vnum=vnum, full_weeks=full_weeks, qdebug=qdebug, $
	ibyt=ibyt, filnam=filnam, $
	flag=flag, infil=infil			;old parameters
;
;+
;NAME:
;	rd_pnt
;PURPOSE:
;	Read the Yohkoh pointing log file.  It reads the ATR file.
;CALLING SEQUENCE:
;	rd_pnt, roadmap(0),  roadmap(n), pnt
;	rd_pnt, '1-dec-91', '30-dec-91', pnt
;	rd_pnt,      weeks,       years, pnt
;INPUT:
;		  INPUT CAN BE OF TWO FORMS
;
;		  (A) Input starting and ending times
;	input1	- Starting time in either (i) standard string format,
;		  or (ii) a structure with .time and .day fields
;		  (the 7 element time vector form is not allowed)
;	input2	- Ending time.  If ending time is omitted, the
;		  ending time is set to 24 hours after starting time.
;
;		  (B) Input can be a vector of week/year number
;	input1	- a vector of the week numbers to read
;	input2	- a vector of the year of the week to be read
;		  if the weeks vector is all within one year, the
;		  year parameter can be a scalar.
;OUTPUT:
;	data	- the data structure containing the data in the files
;		  See the structure definition for further information
;OPTIONAL KEYWORD INPUT:
;	indir	- Input directory of data files.  If not present, use
;		  $DIR_GEN_xxx logical directory
;	vnum	- The file version number to use.  If not present, a call
;		  to WEEKID is made and that latest version is used.
;	nearest	- If set, then the time span is adjusted a day at a time
;		  until it finds some data.  It decrements the starting
;		  date by a day and increments the ending date by a day
;		  up to 14 days (28 day total span)
;       full_weeks - If set, then do not extract the entries that just
;                 cover the times covered in the start/end time.  Return
;                 all data for weeks covered by the start/end time. This
;                 allows a user to have start and end time be the same
;                 and still get some data.
;OPTIONAL KEYWORD OUTPUT:
;	status	- The read status
;		  Some data is available if (status le 0)
;			 0 = no error
;			 1 = cannot find the file
;			 2 = cannot find data in the time period
;			-1 = found data, but had to go outside of the requested
;			     period (only true if /NEAREST is used).  
;	flag	- Error word (same as "status" but kept so that there
;		  is compatablility with the old RD_PNT program.
;			Value = 0 means ok
;			Value = 1 means could not find file(s)
;COMMENTS:
;       The pointing data files must be located in the $DIR_GEN_PNT
;       directory.
;
;	Data is returned in blocks of orbits, so even if the input
;	time spans 5 minutes, approximately 60 minutes of data could be
;	returned.
;HISTORY:
;	Written Feb-92 by M.Morrison
;	 5-Mar-92 (MDM) fix various bugs
;	 8-Mar-92 (MDM) Added "infil" option
;	20-apr-92 (JRL) Fixed "infil" option
;	23-Apr-92 (MDM) Minor adjustments to code
;	 5-May-92 (MDM) added "flag" option
;	22-May-92 (MDM) Fixed bug where trying to access the last orbit
;			of data in the PNT file.
;	18-Jul-92 (MDM) Added "filnam" and "ibyt" option
;	23-Sep-92 (MDM) Modification to grab the proper orbit when the
;			input time is exactly the start time of the orbit
;	23-Oct-92 (MDM) Revamp logic to select orbits to use.  Introducted
;			SEL_TIMRANGE.
;	29-Oct-92 (MDM) Modification to SEL_TIMRANGE so 23-Oct-92 version
;			would work right
;	30-Oct-92 (MDM) More SEL_TIMRANGE modifications - it was missing the
;			the last orbit in a selected time range
;	23-Nov-92 (MDM) Added comments to the header
;	25-Nov-92 (MDM) Corrected special error where the pointer points past
;			the last dataset (error since MK_PNT makes a pointer
;			for the last orbit, even if there is no data).
;	 8-Feb-93 (MDM) Adjustment since temporary PNT file can have data out
;			of order, which is causing problems.
;	12-Jul-93 (MDM) Corrected error which occurs when reading across a
;			year boundary
;			--------------------------------------------------
;	13-Oct-93 (MDM) Removed the code and replaced it with a call to 
;			RD_WEEK_FILE.  It will read the ATR file if present
;			and will the default back to the PNT file
;-
;
status = 1
pnt_data = 0b
;
if (keyword_set(infil)) then begin
    print, 'RD_PNT no longer accepts "INFIL as a keyword input'
    return
end
;
if (ydb_exist([input1, input2], 'atr', /range, qdebug=qdebug)) then prefix = 'ATR' else prefix = 'PNT'
;
rd_week_file, input1, input2, prefix, pnt_data, $
	vnum=vnum, indir=indir, nearest=nearest, status=status, $
	/full_weeks, qdebug=qdebug, $
	ibyt=ibyt, filename=filnam
flag = status
;
end
