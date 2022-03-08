	FUNCTION STR2UTC, UTC, EXTERNAL=EXTERNAL, DMY=DMY, MDY=MDY, $
		ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	STR2UTC()
;
; Purpose     :	Parses UTC time strings.
;
; Explanation :	This procedure parses UTC time strings to extract the date and
;		time.
;
; Use         :	Result = STR2UTC( UTC )
;		Result = STR2UTC( UTC, /EXTERNAL )
;
; Inputs      :	UTC	= A character string containing the date and time.  The
;			  target format is the CCSDS ASCII Calendar Segmented
;			  Time Code format (ISO 8601), e.g.
;
;				"1988-01-18T17:20:43.123Z"
;
;			  The "Z" is optional.  The month and day can be
;			  replaced with the day-of-year, e.g.
;
;				"1988-018T17:20:43.123Z"
;
;			  Other variations include
;
;				"1988-01-18T17:20:43.12345"
;				"1988-01-18T17:20:43"
;				"1988-01-18"
;				"17:20:43.123"
;
;			  Also, the "T" can be replaced by a blank, and the
;			  dashes "-" can be replaced by a slash "/".  This is
;			  the format used by the SoHO ECS.
;
;			  In addition this routine can parse dates where only
;			  two digits of the year is given--the year is assumed
;			  to be between 1950 and 2049.  Character string
;			  months, e.g. "JAN" or "January", can be used instead
;			  of the number.
;
;			  Dates in a different order than year-month-day are
;			  supported, but only through the /MDY and /DMY
;			  keywords.  The only exceptions are dates where the
;			  month is given as a character string, and the year is
;			  given with all four digits, e.g. "18-JAN-1988" or
;			  "Jan-18-1988".
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is a structure containing the (long
;		integer) tags:
;
;			MJD:	The Modified Julian Day number.
;			TIME:	The time of day, in milliseconds since the
;				beginning of the day.
;
;		Alternatively, if the EXTERNAL keyword is set, then the result
;		is a structure with the elements YEAR, MONTH, DAY, HOUR,
;		MINUTE, SECOND, and MILLISECOND.
;
;		Any elements not found in the input character string will be
;		set to zero.		
;
; Opt. Outputs:	None.
;
; Keywords    :	EXTERNAL = If set, then the output is in CDS external format,
;			   as described above.
;		DMY	 = Normally the date is in the order year-month-day.
;			   However, if DMY is set then the order is
;			   day-month-year.
;		MDY	 = If set, then the date is in the order
;			   month-day-year.
;		ERRMSG	 = If defined and passed, then any error messages 
;			   will be returned to the user in this parameter 
;			   rather than being handled by the IDL MESSAGE 
;			   utility.  If no errors are encountered, then a null 
;			   string is returned.  In order to use this feature, 
;			   the string ERRMSG must be defined first, e.g.,
;
;				ERRMSG = ''
;				RESULT = STR2UTC( UTC, ERRMSG=ERRMSG )
;				IF ERRMSG NE '' THEN ...
;
; Calls       :	DATATYPE, DATE2MJD, UTC2INT, MJD2DATE, VALID_NUM
;
; Common      :	None.
;
; Restrictions:	The components of the time must be separated by the colon ":"
;		character, except between the seconds and fractional seconds
;		parts, where the separator is the period "." character.
;
;		The components of the date must be separated by either the dash
;		"-" or slash "/" character.
;
;		The only spaces allowed are at the beginning or end of the
;		string, or between the date and the time.
;
;		This routine does not check to see if the dates entered are
;		valid.  For example, it would not object to the date
;		"1993-February-31", even though there is no such date.
;
; Side effects:	If an error is encountered and the ERRMSG keyword is set, 
;		STR2UTC returns an integer scalar equal to -1.
;
; Category    :	Utilities, Time.
;
; Prev. Hist. :	Part of the logic of this routine is taken from TIMSTR2EX by M.
;		Morrison, LPARL.  However, the behavior of this routine is
;		different from the Yohkoh routine.  Also, the concept of
;		"internal" and "external" time is based in part on the Yohkoh
;		software by M. Morrison and G. Linford, LPARL.
;
; Written     :	William Thompson, GSFC, 13 September 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 21 September 1993.
;		Version 2, William Thompson, GSFC, 28 September 1993.
;			Expanded the capabilities of this routine based on
;  			TIMSTR2EX.
;		Version 3, William Thompson, GSFC, 20 October 1993.
;			Corrected small bug when the time string contains
;			fractional milliseconds, as suggested by Mark Hadfield,
;			NIWA Oceanographic.
;		Version 4, William Thompson, GSFC, 18 April 1994.
;			Corrected bugs involved with passing arrays as
;			input--routine was not calling itself reiteratively
;			correctly.
;		Version 5, Donald G. Luttermoser, GSFC/ARC, 28 December 1994
;			Added the keyword ERRMSG.
;		Version 6, William Thompson, GSFC, 25 January 1995
;			Changed to call intrinsic ROUND instead of NINT.  The
;			version of NINT in the Astronomy User's Library doesn't
;			automatically select between short and long integers as
;			the CDS version does.
;		Version 7, William Thompson, GSFC, 26 January 1995
;			Modified to support VMS-style format.
;			Made error-handling more robust.
;		Version 8, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG keyword to internally called procedures.
;			Note that this routine can handle both scalars and
;			vectors as input.
;		Version 9, William Thompson, GSFC, 2 February 1995
;			Fixed bug with years input with two-digits.
;		Version 10, William Thompson, GSFC, 22 March 1995
;			Fixed bug when date string contains OCT in capital
;			letters.
;
; Version     :	Version 10, 22 March 1995
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
	MONTHS = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', $
		'SEP', 'OCT', 'NOV', 'DEC']
;
;  Check the input array.
;
	IF N_PARAMS() NE 1 THEN BEGIN
		MESSAGE = 'Syntax:  Result = STR2UTC( UTC )'
	ENDIF ELSE BEGIN
		IF DATATYPE(UTC,1) NE 'String' THEN MESSAGE =	$
			'Input parameter to STR2UTC must be of type string.'
	ENDELSE
	IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
;
;  Form the structure to be returned.
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
;  If UTC is an array, then call this routine recursively to interpret each
;  element individually.
;
	SZ = SIZE(UTC)
	IF SZ(0) GE 1 THEN BEGIN
		DATE = REPLICATE(DATE, N_ELEMENTS(UTC))
		FOR I=0,N_ELEMENTS(UTC)-1 DO BEGIN
			DT = STR2UTC(UTC(I), /EXTERNAL, DMY=DMY, MDY=MDY, $
				ERRMSG=ERRMSG)
			IF N_ELEMENTS(ERRMSG) NE 0 THEN	$
				IF ERRMSG(0) NE '' THEN RETURN, -1
			DATE(I).YEAR   = DT.YEAR
			DATE(I).MONTH  = DT.MONTH
			DATE(I).DAY    = DT.DAY
			DATE(I).HOUR   = DT.HOUR
			DATE(I).MINUTE = DT.MINUTE
			DATE(I).SECOND = DT.SECOND
			DATE(I).MILLISECOND = DT.MILLISECOND
		ENDFOR
		DATE = REFORM(DATE, SZ(1:SZ(0)))
		GOTO, FINISH
	ENDIF
;
;  Separate the input string into the date and time parts.  Make sure not to
;  confuse the "T" in "OCT" for the separator between the date and time parts
;  in a CCSDS formatted string.
;
	UT = STRTRIM(UTC,2)
	START = STRPOS(UT,'OCT')
	IF START GE 0 THEN START = START + 3 ELSE START = 0
	SEP = STRPOS(UT,'T',START) > STRPOS(UT,' ',START)
	IF SEP LT 0 THEN BEGIN
		DTSEP = STRPOS(UT,'-') > STRPOS(UT,'/')
		IF DTSEP GE 0 THEN BEGIN
			DT = UT
			TIME = ''
		END ELSE BEGIN
			DT = ''
			TIME = UT
		ENDELSE
	END ELSE BEGIN
		DT = STRMID(UT,0,SEP)
		TIME = STRTRIM(STRMID(UT,SEP+1,STRLEN(UT)-SEP-1),2)
	ENDELSE
;
;  If the date contains the colon ":" character, then the date and time are
;  reversed.
;
	IF STRPOS(DT,':') GE 0 THEN BEGIN
		TEMP = DT
		DT = TIME
		TIME = TEMP
	ENDIF
;
;  Decide whether or not the date is given as year, month, day or as year,
;  day-of-year.  If the latter, calculate the month and day from the Modified
;  Julian Day number.
;
	IF STRPOS(DT,'-') GE 0 THEN DTSEP = '-' ELSE DTSEP='/'
	DT = STR_SEP(DT,DTSEP)
;
;  Day-of-year variation.
;
	IF N_ELEMENTS(DT) EQ 2 THEN BEGIN
		IF NOT (VALID_NUM(DT(0)) AND VALID_NUM(DT(1))) THEN BEGIN
		    MESSAGE ='Unrecognizable date format - Year/DOY variation.'
		    GOTO, HANDLE_ERROR
		ENDIF
		YEAR = FIX(DT(0))
		DOY  = FIX(DT(1))
		IF DOY GE 1000 THEN BEGIN
			YEAR = FIX(DT(1))
			DOY  = FIX(DT(0))
		ENDIF
;
;  If the year is only two digits, then assume that the year is between 1950
;  and 2049.
;
		IF YEAR LT 100 THEN YEAR = ((YEAR + 50) MOD 100) + 1950
		MJD = DATE2MJD(YEAR,DOY,ERRMSG=ERRMSG)
		IF N_ELEMENTS(ERRMSG) NE 0 THEN	$
			IF ERRMSG(0) NE '' THEN RETURN, -1
		MJD2DATE,MJD,YEAR,MONTH,DAY,ERRMSG=ERRMSG
		IF N_ELEMENTS(ERRMSG) NE 0 THEN	$
			IF ERRMSG(0) NE '' THEN RETURN, -1
;
;  Year, month, and day variation.  First select out the three components
;  depending on the settings of the keywords.
;
	END ELSE IF N_ELEMENTS(DT) EQ 3 THEN BEGIN
		IF KEYWORD_SET(DMY) THEN BEGIN
			YEAR = DT(2)
			MONTH = DT(1)
			DAY = DT(0)
		END ELSE IF KEYWORD_SET(MDY) THEN BEGIN
			YEAR = DT(2)
			MONTH = DT(0)
			DAY = DT(1)
		END ELSE BEGIN
			YEAR = DT(0)
			MONTH = DT(1)
			DAY = DT(2)
;
;  If the day field is four digits, and the month field has three characters,
;  then assume that the VMS-style variation (DD-MMM-YYYY) is being used.
;
			IF (STRLEN(DAY) EQ 4) AND (STRLEN(MONTH) EQ 3) THEN $
					BEGIN
				YEAR = DT(2)
				DAY = DT(0)
;
;  Or if the day field is four digits, and the year field has three characters,
;  then assume that the date is in MMM-DD-YYYY format.
;
			END ELSE IF (STRLEN(DAY) EQ 4) AND	$
					(STRLEN(YEAR) EQ 3) THEN BEGIN
				YEAR = DT(2)
				MONTH = DT(0)
				DAY = DT(1)
			ENDIF
		ENDELSE
;
;  Convert the day to a number.
;
		IF NOT VALID_NUM(DAY) THEN BEGIN
			MESSAGE = 'Unrecognizable date format - day.'
			GOTO, HANDLE_ERROR
		END ELSE DAY = FIX(DAY)
;
;  If the year is only two digits, then assume that the year is between 1950
;  and 2049.
;
		IF NOT VALID_NUM(YEAR) THEN BEGIN
			MESSAGE = 'Unrecognizable date format - year.'
			GOTO, HANDLE_ERROR
		END ELSE YEAR = FIX(YEAR)
		IF YEAR LT 100 THEN YEAR = ((YEAR + 50) MOD 100) + 1950
;
;  If the month is not a number, then assume that it is a month string.
;
		IF NOT VALID_NUM(MONTH) THEN BEGIN
			MONTH = STRUPCASE(STRMID(MONTH,0,3))
			MONTH = (WHERE(MONTH EQ MONTHS) + 1)(0)
			IF MONTH EQ 0 THEN BEGIN
				MESSAGE = 'Unrecognizable date format - month.'
				GOTO, HANDLE_ERROR
			ENDIF
		END ELSE MONTH = FIX(MONTH)
;
;  No date.
;
	END ELSE IF TOTAL(STRLEN(DT)) EQ 0 THEN BEGIN
		YEAR = 0
		MONTH = 0
		DAY = 0
	END ELSE BEGIN
		MESSAGE = 'Unrecognizable date format.'
		GOTO, HANDLE_ERROR
	ENDELSE
;
;  Parse the time.  First remove any trailing Z characters.
;
	Z = STRPOS(TIME,'Z')
	IF Z GT 0 THEN TIME = STRMID(TIME,0,Z)
	TM = STRARR(3)
	TM(0) = STR_SEP(TIME,':')
	IF (STRLEN(TM(0)) GT 0) AND NOT VALID_NUM(TM(0)) THEN BEGIN
		MESSAGE = 'Unrecognizable date format - hour.'
		GOTO, HANDLE_ERROR
	END ELSE HOUR = FIX(TM(0))
	IF (STRLEN(TM(1)) GT 0) AND NOT VALID_NUM(TM(1)) THEN BEGIN
		MESSAGE = 'Unrecognizable date format - minute.'
		GOTO, HANDLE_ERROR
	END ELSE MINUTE = FIX(TM(1))
	IF (STRLEN(TM(2)) GT 0) AND NOT VALID_NUM(TM(2)) THEN BEGIN
		MESSAGE = 'Unrecognizable date format - second.'
		GOTO, HANDLE_ERROR
	END ELSE SECOND = DOUBLE(TM(2))
;
;  Store everything in the structure variable, and return.
;
	DATE.YEAR   = YEAR
	DATE.MONTH  = MONTH
	DATE.DAY    = DAY
	DATE.HOUR   = HOUR
	DATE.MINUTE = MINUTE
	MILLISECOND = ROUND(1000*SECOND)
	DATE.SECOND = MILLISECOND / 1000
	DATE.MILLISECOND = MILLISECOND MOD 1000
;
;  If the EXTERNAL keyword is not set, then convert the date into the CDS
;  internal format.
;
FINISH:
	IF NOT KEYWORD_SET(EXTERNAL) THEN DATE = UTC2INT(DATE,ERRMSG=ERRMSG)
	IF N_ELEMENTS(ERRMSG) NE 0 THEN $
		IF ERRMSG(0) EQ '' THEN ERRMSG = MESSAGE
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
