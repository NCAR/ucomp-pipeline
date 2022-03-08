	FUNCTION UTC2DOY, UTC, FRACTIONAL=FRACTIONAL, ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	UTC2DOY()
;
; Purpose     :	Calculates the day of the year from CDS UTC date/time.
;
; Explanation :	This procedure takes any of the UTC date/time formats, and
;		calculates the appropriate day of the year, starting with the
;		1st of January as day 1.
;
;		See file aaareadme.txt for a listing of the proper UTC
;		date/time formats.
;
; Use         :	Result = UTC2DOY( UTC )
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
; Outputs     :	The result of the function is the day of the year.
;
; Opt. Outputs:	None.
;
; Keywords    :	FRACTIONAL   =	If set, then a fractional day-of-year will be
;				returned, instead of a whole number.
;
;		ERRMSG       =	If defined and passed, then any error messages 
;				will be returned to the user in this parameter 
;				rather than being handled by the IDL MESSAGE 
;				utility.  If no errors are encountered, then a 
;				null string is returned.  In order to use this 
;				feature, the string ERRMSG must be defined 
;				first, e.g.,
;
;					ERRMSG = ''
;					RESULT = UTC2DOY( UTC, ERRMSG=ERRMSG )
;					IF ERRMSG NE '' THEN ...
;
; Calls       :	STR2UTC, UTC2INT
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	If an error is encountered and the ERRMSG keyword is set, 
;		UTC2DOY returns an integer scalar equal to -1.
;
; Category    :	Utilities, Time.
;
; Prev. Hist. :	None.
;
; Written     :	William Thompson, GSFC, 27 September 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 27 September 1993.
;		Version 2, William Thompson, GSFC, 14 November 1994
;			Changed .DAY to .MJD
;		Version 3, Donald G. Luttermoser, GSFC/ARC, 28 December 1994
;			Added the keyword ERRMSG.  Added a check to see
;			whether the calculated DOY is valid.
;		Version 4, Donald G. Luttermoser, GSFC/ARC, 3 January 1995
;			Fixed bug introduced in version 3 which did not allow
;			for arrays to be sent/returned.
;		Version 5, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG keyword to internally called procedures.
;			Madec the error handling routine more robust.  Note
;			that this procedure can handle both scalars and 
;			vectors as input.
;		Version 6, William Thompson, GSFC, 28 January 1997
;			Allow for long input arrays.
;		Version 7, 07-Mar-2000, William Thompson, GSFC
;			Added keyword FRACTIONAL
;               Version 8, William Thompson, GSFC, 25-Oct-2005
;                       Treat all structures with MJD and TIME tags as CDS
;                       internal time
;
; Version     :	Version 8, 25-Oct-2005
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Check the input parameter.
;
	IF N_PARAMS() NE 1 THEN BEGIN
		MESSAGE = 'Syntax:  Result = UTC2DOY( UTC )'
		GOTO, HANDLE_ERROR
	ENDIF

	CASE DATATYPE(UTC,1) OF
		'String':	UT = STR2UTC(UTC,/EXTERNAL,ERRMSG=MESSAGE)
		'Structure':	BEGIN
                    IF TAG_EXIST(UTC,'mjd',/TOP_LEVEL) AND $
                      TAG_EXIST(UTC,'time',/TOP_LEVEL) THEN BEGIN
                        MJD = UTC.MJD
                        UT = INT2UTC(UTC,ERRMSG=MESSAGE)
                    END ELSE IF N_TAGS(UTC) EQ 7 THEN UT = UTC ELSE $
                      MESSAGE = 'Unrecognized UTC structure.'
                END
		ELSE:  MESSAGE = 'UTC must be either a string or a structure.'
	ENDCASE
	IF MESSAGE NE '' THEN GOTO,HANDLE_ERROR
	CHECK_EXT_TIME, UT
;
;  Calculate the Modified Julian Day number from the date, and do the same for
;  January 1st of the same year.  The difference, plus 1, is the day-of-year.
;
	IF N_ELEMENTS(MJD) EQ 0 THEN MJD = DATE2MJD(UT.YEAR,UT.MONTH,UT.DAY)
	MJD0 = DATE2MJD(UT.YEAR,1,1)
;
	DOY = MJD - MJD0 + 1
	FOR IDOY=0L,N_ELEMENTS(DOY)-1 DO BEGIN
		IF (DOY(IDOY) LT 1) OR (DOY(IDOY) GT 366) THEN BEGIN
			MESSAGE = 'Input date-time not in proper format.'
			GOTO, HANDLE_ERROR
		ENDIF
	ENDFOR
;
	IF KEYWORD_SET(FRACTIONAL) THEN DOY = DOY + (UT.HOUR + (UT.MINUTE + $
		((UT.SECOND<59) + UT.MILLISECOND/1000.D0)/60.D0)/60.D0)/24.D0
;
	IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
	RETURN, DOY
;
;  Error handling point.
;
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) EQ 0 THEN MESSAGE, MESSAGE
	ERRMSG = MESSAGE
	RETURN, -1
;
	END
