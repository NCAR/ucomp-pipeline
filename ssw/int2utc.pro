	FUNCTION INT2UTC, INT, CCSDS=CCSDS, ECS=ECS, VMS=VMS, STIME=STIME, $
		TRUNCATE=TRUNCATE, DATE_ONLY=DATE_ONLY, TIME_ONLY=TIME_ONLY, $
		UPPERCASE=UPPERCASE, NOZ=NOZ, ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	INT2UTC()
;
; Purpose     :	Converts CDS internal time to calendar format.
;
; Explanation :	This procedure takes the UTC calendar time in "internal" format
;		(Modified Julian Day number, and time of day in milliseconds),
;		and converts it to a calendar format, either as a structure or
;		as a string.  For notes on other time formats, see file
;		aaareadme.txt.
;
; Use         :	Result = INT2UTC( INT )
;		Result = INT2UTC( INT, /CCSDS )
;		Result = INT2UTC( INT, /ECS )
;
; Inputs      :	INT	= The UTC date/time as a data structure with the
;			  elements:
;
;				MJD	= The Modified Julian Day number
;				TIME	= The time of day, in milliseconds
;					  since the start of the day.
;
;			  Both are long integers.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function will be a structure containing the
;		tag elements YEAR, MONTH, DAY, HOUR, MINUTE, SECOND, and
;		MILLISECOND.
;
;		Alternatively, if the CCSDS switch is set, then the result will
;		be the calendar date in the format recommended by the
;		Consultative Committee for Space Data Systems (ISO 8601), e.g.
;
;			"1988-01-18T17:20:43.123Z"
;
;		Or if the ECS switch is set, then the result will be a calendar
;		date in the format used by the EOF Core System, e.g.
;
;			"1988/01/18 17:20:43.123"
;
;		Note that this isn't exactly the ECS string format, because the
;		ECS does not use fractional seconds.  However, if /ECS is
;		combined with /TRUNCATE, then the following output will result
;
;			"1988/01/18 17:20:43"
;
;		which matches what the ECS expects to see.
;
;		Using the keyword /VMS writes out the time in a format similar
;		to that used by the VMS operating system, e.g.
;
;			"18-Jan-1988 17:20:43.123"
;
;		A variation of this is obtained with the /STIME keyword, which
;		emulates the value of !STIME in IDL.  It is the same as using
;		/VMS except that the time is only output to 0.01 second
;		accuracy, e.g.
;
;			"18-Jan-1988 17:20:43.12"
;
;		The keywords /DATE_ONLY and TIME_ONLY can be used to extract
;		either the date or time part of the string.
;
; Opt. Outputs:	None.
;
; Keywords    :	CCSDS	  = If set, then the output is in CCSDS format, as
;			    explained above.
;
;		ECS	  = If set, then the output is in ECS format, as
;			    explained above.
;
;		VMS	  = If set, then the output will be in VMS format, as
;			    described above.
;
;		STIME	  = If set, then the output will be in STIME format, as
;			    described above.
;
;		Only one of the above keywords can be set.  If none of them are
;		set, the the time is output in external format.  The following
;		keywords are only valid if one of the above keywords is set.
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
;		ERRMSG	  = If defined and passed, then any error messages 
;			    will be returned to the user in this parameter 
;			    rather than being handled by the IDL MESSAGE 
;			    utility.  If no errors are encountered, then a null
;			    string is returned.  In order to use this feature,
;			    the string ERRMSG must be defined first, e.g.,
;
;				ERRMSG = ''
;				MJD = INT2UTC ( INT, ERRMSG=ERRMSG )
;				IF ERRMSG NE '' THEN ...
;
; Calls       :	DATATYPE, UTC2STR, MJD2DATE, TAG_EXIST
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	The result of an array with a single element may be a scalar.
;		If an error occurs and the ERRMSG keyword has been set, the
;		result returned from INT2UTC is an integer scalar of value -1.
;
; Category    :	Utilities, Time.
;
; Prev. Hist. :	None.  However, the concept of "internal" and "external" time
;		is based in part on the Yohkoh software by M. Morrison and G.
;		Linford, LPARL.
;
; Written     :	William Thompson, GSFC, 20 September 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 21 September 1993.
;		Version 2, William Thompson, GSFC, 14 November 1994
;			Changed .DAY to .MJD
;		Version 3, William Thompson, GSFC, 20 December 1994
;			Added keywords TRUNCATE, DATE_ONLY, TIME_ONLY
;		Version 4, Donald G. Luttermoser, GSFC/ARC, 28 December 1994
;			Added the keyword ERRMSG.  Added check to the structure
;			tag names in INT.
;		Version 5, William Thompson, GSFC, 25 January 1995
;			Changed to call intrinsic ROUND instead of NINT.  The
;			version of NINT in the Astronomy User's Library doesn't
;			automatically select between short and long integers as
;			the CDS version does.
;		Version 6, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG keyword to internally called procedures.
;			Made the error handling procedure more robust.  Note
;			that this routine accepts both scalar and vector 
;			input.
;		Version 7, William Thompson, GSFC, 14 March 1995
;			Added keywords VMS, STIME, UPPERCASE
;		Version 8, William Thompson, GSFC, 17 September 1997
;			Added keyword NOZ.
;               Version 9, William Thompson, GSFC, 25-Oct-2005
;                       Interpret any structure with tags MJD and TIME as CDS
;                       internal time.
;
; Version     :	Version 9, 25-Oct-2005
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Check the input array.
;
	IF N_PARAMS() NE 1 THEN BEGIN
		MESSAGE = 'Syntax:  Result = INT2UTC( INT )'
	ENDIF ELSE BEGIN
		IF DATATYPE(INT,1) NE 'Structure' THEN BEGIN
			MESSAGE = 'INT must be a structure variable.'
		ENDIF ELSE BEGIN
                    IF NOT (TAG_EXIST(INT,'mjd',/TOP_LEVEL) AND $
                      TAG_EXIST(INT,'time',/TOP_LEVEL)) THEN MESSAGE = $
                      'INT must have two tags: INT = {MJD: ,TIME: }.'
		ENDELSE
	ENDELSE
	IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
;
;  Format the output into a structure.
;
	DATE = {CDS_EXT_TIME,	$
		YEAR:	0,	$
		MONTH:	0,	$
		DAY:	0,	$
		HOUR:	0,	$
		MINUTE:	0,	$
		SECOND:	0,	$
		MILLISECOND: 0}
;
;  Expand DATE if input parameter is an array.
;
	IF N_ELEMENTS(INT) GT 1 THEN BEGIN
		DATE = REPLICATE(DATE, N_ELEMENTS(INT))
		SZ = SIZE(INT)
		DATE = REFORM(DATE,SZ(1:SZ(0)))
	ENDIF
;
;  From the Modified Julian Day number, calculate the year, month, and day.
;
	MJD2DATE, INT.MJD, YEAR, MONTH, DAY, ERRMSG=ERRMSG
	IF N_ELEMENTS(ERRMSG) NE 0 THEN $
		IF ERRMSG(0) NE '' THEN RETURN, -1
	DATE.YEAR   = YEAR
	DATE.MONTH  = MONTH
	DATE.DAY    = DAY
;
;  From the time in milliseconds, calculate the hour, minute, and seconds.
;  Make sure that a leap second would appear as 23:59:60.
;
	SEC = INT.TIME / 1000.D0
	DATE.HOUR = FIX(SEC / 3600.D0) < 23
	SEC = SEC - DATE.HOUR * 3600.D0
	DATE.MINUTE = FIX(SEC / 60.D0) < 59
	SEC = SEC - DATE.MINUTE * 60.D0
	DATE.SECOND = FIX(SEC)
	DATE.MILLISECOND = ROUND(1000*(SEC - DATE.SECOND))
;
;  If one of the keywords CCSDS, ECS, VMS or STIME was set, then convert the
;  date to that format.
;
	IF KEYWORD_SET(CCSDS) OR KEYWORD_SET(ECS) OR KEYWORD_SET(VMS) OR $
			KEYWORD_SET(STIME) THEN BEGIN
		DATE = UTC2STR(DATE, ECS=ECS, VMS=VMS, STIME=STIME,	$
			TRUNCATE=TRUNCATE, DATE_ONLY=DATE_ONLY,		$
			TIME_ONLY=TIME_ONLY, UPPERCASE=UPPERCASE,	$
			NOZ=NOZ, ERRMSG=ERRMSG)
		IF N_ELEMENTS(ERRMSG) NE 0 THEN $
			IF ERRMSG(0) NE '' THEN RETURN, -1
	ENDIF
;
	IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
	RETURN, DATE
;
;  Error handling point.
;
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) EQ 0 THEN MESSAGE, MESSAGE
	ERRMSG = MESSAGE
	RETURN, -1
;
	END
