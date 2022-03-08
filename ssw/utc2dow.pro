	FUNCTION UTC2DOW, UTC, STRING=STRING, ABBREVIATED=ABBREVIATED, $
		ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	UTC2DOW()
;
; Purpose     :	Calculates the day of the week from CDS UTC date/time.
;
; Explanation :	This procedure takes any of the UTC date/time formats, and
;		calculates the appropriate day of the week.  This is returned
;		as either a number between 0-6 (Sunday-Saturday), or as a three
;		letter character string (e.g. "Mon") or as a longer character
;		string (e.g. "Monday").
;
; Use         :	Result = UTC2DOW( UTC )
;		Result = UTC2DOW( UTC, /STRING )
;		Result = UTC2DOW( UTC, /ABBREVIATED )
;		Result = STRUPCASE( UTC2DOW( UTC, /ABBREVIATED ))
;
; Inputs      :	UTC	= Coordinated Universal Time, in one of the following
;			  formats:
;
;			Internal:  A structure containing the tags:
;
;				MJD:	The Modified Julian Day number.
;				TIME:	The time of day, in milliseconds since
;					the beginning of the day.
;
;				   Both are long integers.
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
;				   or one of its variants--see STR2UTC for
;				   more details.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is the day of the week in one of the
;		following formats:
;
;			     Default	String	    Abbreviated
;
;				0	Sunday		Sun
;				1	Monday		Mon
;				2	Tuesday		Tue
;				3	Wednesday	Wed
;				4	Thursday	Thu
;				5	Friday		Fri
;				6	Saturday	Sat
;
; Opt. Outputs:	None.
;
; Keywords    :	STRING	    = If set, then the result of the function is a
;			      character string containing the full name of the
;			      day of the week, e.g. "Monday".
;
;		ABBREVIATED = If set, then the result of the function is a
;			      three-letter abbreviation for the day of the
;			      week, e.g. "Mon".  If all uppercase letters are
;			      desired, e.g. "TUE", then simply combine this
;			      function with the STRUPCASE function.
;
;		ERRMSG	    = If defined and passed, then any error messages 
;			      will be returned to the user in this parameter 
;			      rather than being handled by the IDL MESSAGE 
;			      utility.  If no errors are encountered, then a 
;			      null string is returned.  In order to use this 
;			      feature, the string ERRMSG must be defined 
;			      first, e.g.,
;
;				ERRMSG = ''
;				RESULT = UTC2DOW( UTC, ERRMSG=ERRMSG )
;				IF ERRMSG NE '' THEN ...
;
; Calls       :	STR2UTC, UTC2INT
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	If an error is encountered and the ERRMSG keyword is set, 
;		UTC2DOW returns an integer scalar equal to -1.
;
; Category    :	Utilities, Time.
;
; Prev. Hist. :	None.
;
; Written     :	William Thompson, GSFC, 27 September 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 27 September 1993.
;		Version 2, William Thompson, GSFC, 14 November 1994.
;			Changed .DAY to .MJD
;		Version 3, Donald G. Luttermoser, GSFC/ARC, 28 December 1994.
;			Added the keyword ERRMSG.
;		Version 4, Donald G. Luttermoser, GSFC/ARC, 30 January 1995.
;			Added ERRMSG keyword to internally called procedures.
;			Made the error handling routine more robust.  Note 
;			that this procedure can handle both scalars and
;			vectors as input.
;               Version 5, William Thompson, GSFC, 25-Oct-2005
;                       Pass all structure interpretation to UTC2INT - treats
;                       structures with MJD and TIME as CDS internal time
;
; Version     :	Version 5, 25-Oct-2005
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Check the input parameter.
;
	IF N_PARAMS() NE 1 THEN BEGIN
		MESSAGE = 'Syntax:  Result = UTC2DOW( UTC )'
		GOTO, HANDLE_ERROR
	ENDIF

	CASE DATATYPE(UTC,1) OF
		'String':	UT = STR2UTC(UTC, ERRMSG=MESSAGE)
		'Structure':	UT = UTC2INT(UTC, ERRMSG=MESSAGE)
		ELSE:  MESSAGE = 'UTC must be either a string or a structure.'
	ENDCASE
	IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
;
;  Define the character strings for the days of the week.
;
	SHORT_DOW = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
	FULL_DOW = ['Sunday','Monday','Tuesday','Wednesday','Thursday',	$
		'Friday','Saturday']
;
;  Calculate the day of the week from the date.
;
	DOW = (UT.MJD + 3) MOD 7
	IF KEYWORD_SET(ABBREVIATED) THEN BEGIN
		DOW = SHORT_DOW(DOW)
	END ELSE IF KEYWORD_SET(STRING) THEN BEGIN
		DOW = FULL_DOW(DOW)
	ENDIF
;
	IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
	RETURN, DOW
;
; Error handling point.
;
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) EQ 0 THEN MESSAGE, MESSAGE
	ERRMSG = MESSAGE
	RETURN, -1
;
	END
