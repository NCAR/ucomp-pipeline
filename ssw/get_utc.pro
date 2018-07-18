	PRO GET_UTC, UTC, EXTERNAL=EXTERNAL, CCSDS=CCSDS, ECS=ECS, VMS=VMS, $
		STIME=STIME, TRUNCATE=TRUNCATE, DATE_ONLY=DATE_ONLY,	$
		TIME_ONLY=TIME_ONLY, UPPERCASE=UPPERCASE, NOZ=NOZ,	$
		ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	GET_UTC
;
; Purpose     :	Gets the current date/time in UTC.
;
; Explanation :	This procedure uses the IDL SYSTIME() function to calculate
;		the current UTC date/time, and formats it into one of the CDS
;		standard UTC time formats.  For notes on various time formats,
;		see file aaareadme.txt.
;
; Use         :	GET_UTC, UTC
;		GET_UTC, UTC, /EXTERNAL
;		GET_UTC, UTC, /CCSDS
;		GET_UTC, UTC, /ECS
;
; Inputs      :	None.
;
; Opt. Inputs :	None.
;
; Outputs     :	UTC  = The UTC current calendar time in one of several formats,
;		       depending on the keywords passed.
;
;			Internal:  A structure containing the tags:
;
;				MJD:	The Modified Julian Day number.
;				TIME:	The time of day, in milliseconds since
;					the beginning of the day.
;
;				   Both are long integers.  This is the default
;				   format.
;
;			External:  A structure containing the integer tags
;				   YEAR, MONTH, DAY, HOUR, MINUTE, SECOND, and
;				   MILLISECOND.
;
;			CCSDS:	   An ASCII string containing the UTC time to
;				   millisecond accuracy in the format
;				   recommended by the Consultative Committee
;				   for Space Data Systems (ISO 8601), e.g.
;
;					"1988-01-18T17:20:43.123Z"
;
;			ECS:	   Similar to CCSDS, except that the date has
;				   the format:
;
;					"1988/01/18 17:20:43.123"
;
;			VMS:	   The date and time has the format
;
;					"18-JAN-1988 17:20:43.123"
;
;			STIME:	   The date and time has the format
;
;					"18-JAN-1988 17:20:43.12"
;
;				   See UTC2STR for more information
;
; Opt. Outputs:	None.
;
; Keywords    :	EXTERNAL = If set, then the output is in external format, as
;			   explained above.
;
;		CCSDS	 = If set, then the output is in CCSDS format, as
;			   explained above.
;
;		ECS	 = If set, then the output is in ECS format, as
;			   explained above.
;
;		VMS	  = If set, then the output will be in VMS format, as
;			    described above.
;
;		STIME	  = If set, then the output will be in STIME format, as
;			    described above.
;
;		The following keywords are only valid if one of the string
;		formats is selected.
;
;		TRUNCATE  = If set, then the time will be truncated to 1 second
;			    accuracy.  Note that this is not the same thing as
;			    rounding off to the nearest second, but is a
;			    rounding down.
;
;		DATE_ONLY = If set, then only the date part of the string is
;			    returned.
;
;		TIME_ONLY = If set, then only the time part of the string is
;			    returned.
;
;		UPPERCASE = If set, then the month field in either the VMS or
;			    STIME format is returned as uppercase.
;
;		NOZ	  = When set, the "Z" delimiter (which denotes UTC
;			    time) is left off the end of the CCSDS/ISO-8601
;			    string format.  It was decided by the FITS
;			    committee to not append the "Z" in standard FITS
;			    keywords.
;
;		The following keyword is always valid.
;
;		ERRMSG   = If defined and passed, then any error messages will
;			   be returned to the user in this parameter rather
;			   than using the IDL MESSAGE utility.  If no errors
;			   are encountered, then a null string is returned.
;			   In order to use this feature, the string ERRMSG
;			   must be defined first, e.g., 
;
;				ERRMSG = ''
;				GET_UTC, UTC, ERRMSG=ERRMSG
;				IF ERRMSG NE '' THEN ...
;
;
; Calls       :	INT2UTC
;
; Common      :	Uses the internal common block LOCAL_DIFF to store information
;		between calls.  This common block is shared with the routine
;		LOCAL_DIFF.
;
; Restrictions:	This routine depends on the behavior of IDL's SYSTIME function.
;		Currently, it is believed that this routine will return the
;		time in UTC on all properly configured Unix systems.  However,
;		the result may be different in other operating systems; e.g. on
;		VMS and MacIntosh computers it gives the local time instead.
;		It is believed to work correctly in IDL for Windows.
;
;		In order to get around this difficulty, the file
;		"local_diff.dat" can be placed in the directory given by the
;		environment variable TIME_CONV.  If this file exists, then this
;		program will read the value (local-UTC in hours) from this file
;		and use it as a correction factor.  For example, for U.S.
;		Eastern Standard Time, this file would contain the value -5.
;		(See local_diff.pro for more information.)  This means then,
;		that this file must contain the correct value, and must be
;		updated to reflect changes between standard and daylight
;		savings time.
;
;		On the other hand, if the second line in the "local_diff.dat"
;		file reads "GMT", then it is assumed that the computer is
;		running on GMT instead of local time, and no correction is
;		made.
;
;		The file local_diff.dat is only read once.  The contents are
;		stored in a common block between calls.  Once a day, the file
;		is reread.
;
;		The accuracy of the time returned by this routine depends on
;		that of the computer's system clock.
;
; Side effects:	None.
;
; Category    :	Utilities, time.
;
; Prev. Hist. :	None.  However, the concept of "internal" and "external" time
;		is based in part on the Yohkoh software by M. Morrison and G.
;		Linford, LPARL.
;
; Written     :	William Thompson, GSFC, 21 September 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 21 September 1993.
;		Version 2, William Thompson, GSFC, 3 November 1994
;			Added test for "local_diff.dat" file.
;		Version 3, William Thompson, GSFC, 14 November 1994
;			Added test for "GMT" line in "local_diff.dat" file
;			Changed .DAY to .MJD
;		Version 4, William Thompson, GSFC, 17 November 1994
;			Fixed bug introduced in version 3
;		Version 5, William Thompson, GSFC, 20 December 1994
;			Added keywords TRUNCATE, DATE_ONLY, TIME_ONLY
;		Version 6, Donald G. Luttermoser, GSFC/ARC, 20 December 1994
;			Added the keyword ERRMSG.
;		Version 7, William Thompson, GSFC, 25 January 1995
;			Changed to call intrinsic ROUND instead of NINT.  The
;			version of NINT in the Astronomy User's Library doesn't
;			automatically select between short and long integers as
;			the CDS version does.
;		Version 8, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG keyword to internally called procedures.
;			Made the error handling procedures more robust.
;		Version 9, William Thompson, GSFC, 14 March 1995
;			Added keywords VMS, STIME, UPPERCASE
;		Version 10, William Thompson, GSFC, 15 March 1995
;			Changed CDS_TIME to TIME_CONV
;		Version 11, William Thompson, GSFC, 2 June 1997
;			Store information between calls in common block.
;		Version 12, William Thompson, GSFC, 17 September 1997
;			Added keyword NOZ.
;
; Version     :	Version 12, 17-Sep-1997
;-
;
	COMMON LOCAL_DIFF, FILENAME, DIFF, TEST, LAST_READ
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 1 THEN BEGIN
		MESSAGE = 'Syntax:  GET_UTC, UTC'
		GOTO, HANDLE_ERROR
	ENDIF
;
;  Get the current time in seconds since 1 January 1970.  It is assumed that
;  the system time is synchronized with UTC in some way (e.g. through ntp for
;  high accuracy), but that memory of leap seconds insertions is not retained.
;
	SECONDS = SYSTIME(1)
;
;  Check for the existence of local_diff.dat.  If found, then use it as a
;  correction factor.
;
	IF N_ELEMENTS(LAST_READ) EQ 0 THEN LAST_READ = 0
	IF SECONDS GE (LAST_READ+86400.D0) THEN BEGIN
	    FILENAME = FIND_WITH_DEF('local_diff.dat','TIME_CONV')
	    IF FILENAME NE '' THEN BEGIN
		OPENR, UNIT, FILENAME, /GET_LUN
		DIFF = 0.0D0
		READF, UNIT, DIFF
;
;  Check to see if the second line in the file is "GMT".
;
		TEST = ""
		IF NOT EOF(UNIT) THEN READF, UNIT, TEST
		FREE_LUN, UNIT
	    ENDIF
	    LAST_READ = SECONDS
	ENDIF
;
	IF FILENAME NE '' THEN IF STRUPCASE(STRMID(TEST,0,3)) NE 'GMT' THEN $
		SECONDS = SECONDS - DIFF*3600.
;
;  Calculate the Modified Julian Day number, and the number of milliseconds
;  into the day.
;
	DAYSECONDS = 24.D0 * 60.D0^2
	MJD = LONG(SECONDS/DAYSECONDS)
	UTC = {CDS_INT_TIME,		$
		MJD: 40587L + MJD,	$
		TIME: ROUND(1000*(SECONDS-MJD*DAYSECONDS))}
;
;  If one of the optional formats was selected, then call INT2UTC to convert
;  the format.
;
	IF KEYWORD_SET(EXTERNAL) OR KEYWORD_SET(CCSDS) OR KEYWORD_SET(ECS) OR $
			KEYWORD_SET(VMS) OR KEYWORD_SET(STIME) THEN BEGIN
		UTC = INT2UTC(UTC, CCSDS=CCSDS, ECS=ECS, VMS=VMS,	$
			STIME=STIME, TRUNCATE=TRUNCATE, DATE_ONLY=DATE_ONLY, $
			TIME_ONLY=TIME_ONLY, UPPERCASE=UPPERCASE,	$
			NOZ=NOZ, ERRMSG=ERRMSG)
		IF N_ELEMENTS(ERRMSG) NE 0 THEN $
			IF ERRMSG(0) NE '' THEN RETURN
	ENDIF
;
;  Return the UTC date/time.
;
	IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
	RETURN
;
;  Error handling point.
;
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) EQ 0 THEN MESSAGE, MESSAGE
	ERRMSG = MESSAGE
	RETURN
;
	END
