	FUNCTION UTC2TAI, UTC, NOCORRECT=NOCORRECT, ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	UTC2TAI()
;
; Purpose     :	Converts UTC calendar time to TAI.
;
; Explanation :	This procedure converts Coordinated Universal Time (UTC)
;		calendar time, in one of the CDS formats into Atomic
;		International Time (TAI).  For notes on various time formats, 
;		see file aaareadme.txt.
;
; Use         :	Result = UTC2TAI( UTC )
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
; Outputs     :	The result of the function is the Atomic International Time
;		calculated from the date and time, in seconds from midnight on
;		1 January 1958.
;
; Opt. Outputs:	None.
;
; Keywords    :	NOCORRECT = If set, then the time will be assumed to be already
;			    a TAI value, even though apparently in UTC format,
;			    and no adjustment will be made for leap seconds.
;
;                           This keyword can also be used to convert to the
;                           number of non-leap seconds since 1-Jan-1958, as
;                           used by the STEREO spacecraft.
;
;		ERRMSG    = If defined and passed, then any error messages 
;			    will be returned to the user in this parameter 
;			    rather than being handled by the IDL MESSAGE 
;			    utility.  If no errors are encountered, then a 
;			    null string is returned.  In order to use this 
;			    feature, the string ERRMSG must be defined 
;			    first, e.g.,
;
;				ERRMSG = ''
;				RESULT = UTC2TAI( UTC, ERRMSG=ERRMSG )
;				IF ERRMSG NE '' THEN ...
;
; Calls       :	DATATYPE, GET_LEAP_SEC, STR2UTC, UTC2INT
;
; Common      :	None.
;
; Restrictions:	Not valid for dates before 1 January 1972.
;
;		This procedure requires a file containing the dates of all leap
;		second insertions starting with 31 December 1971.  This file
;		must have the name 'leap_seconds.dat', and must be in the
;		directory given by the environment variable TIME_CONV.  It must
;		be properly updated as new leap seconds are announced.
;
; Side effects:	If an error is encountered and the ERRMSG keyword is set, 
;		UTC2TAI returns an integer scalar equal to -1.
;
; Category    :	None.
;
; Prev. Hist. :	None.  However, the concept of "internal" and "external" time
;		is based in part on the Yohkoh software by M. Morrison and G.
;		Linford, LPARL.
;
; Written     :	William Thompson, GSFC, 13 September 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 21 September 1993.
;		Version 2, William Thompson, GSFC, 14 November 1994
;			Changed .DAY to .MJD
;		Version 3, Donald G. Luttermoser, GSFC/ARC, 3 January 1995
;			Added the keyword ERRMSG.
;		Version 4, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG keyword to internally called procedures.
;			Made the error handling routine more robust.  Note
;			that this procedure can handle both scalars and
;			vectors as input.
;		Version 5, William Thompson, GSFC, 28 January 1997
;			Allow for long input arrays.
;		Version 6, William Thompson, GSFC, 7 February 1997
;			Added keyword NOCORRECT
;               Version 7, William Thompson, GSFC, 25-Oct-2005
;                       Handle structures through UTC2INT - interprets any
;                       structure with MJD and TIME as CDS internal time
;		Version 8, William Thompson, GSFC, 3-Jan-2006
;			Use VALUE_LOCATE for IDL 5.3 or higher
;   Version 9, Zarro (GSFC), 18 March 2006
;     Added check for vector input in VALUE_LOCATE
;
; Version     :	Version 8, 3-Jan-2006
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Check the input parameter.
;
	IF N_PARAMS() NE 1 THEN BEGIN
		MESSAGE = 'Syntax:  Result = UTC2TAI( UTC )'
		GOTO, HANDLE_ERROR
	ENDIF

	CASE DATATYPE(UTC,1) OF
		'String':       UT = STR2UTC(UTC,ERRMSG=MESSAGE)
		'Structure':	UT = UTC2INT(UTC,ERRMSG=MESSAGE)
		ELSE:  MESSAGE = 'UTC must be either a string or a structure.'
	ENDCASE
	IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
;
;  Calculate the time of day as the number of seconds into the day.
;
	SECONDS = UT.TIME / 1000.D0
;
;  Correct the time for leap seconds added since 1 January 1958.  Start off
;  with a total of 9 seconds offset just prior to 1 January 1972.  Before that
;  date, a more complicated algorithm was used to determine the difference
;  between TAI and UTC.
;
	IF NOT KEYWORD_SET(NOCORRECT) THEN BEGIN
		SECONDS = SECONDS + 9.D0
;
;  Call GET_LEAP_SEC to return an array containing the dates that leap seconds
;  were inserted.  Correct the times for each leap second.
;
		GET_LEAP_SEC, MJD, ERRMSG=ERRMSG
		IF N_ELEMENTS(ERRMSG) NE 0 THEN $
			IF ERRMSG(0) NE '' THEN RETURN, -1
		IF (!VERSION.RELEASE GE '5.3') and (n_elements(mjd) gt 1) THEN SECONDS = SECONDS + $
			(0.D0 > (VALUE_LOCATE(MJD+1,UT.MJD)+1)) ELSE BEGIN
		    FOR I = 0L,N_ELEMENTS(MJD)-1 DO BEGIN
			W = WHERE(UT.MJD GT MJD(I), NCOUNT)
			IF NCOUNT GT 0 THEN SECONDS(W) = SECONDS(W) + 1
		    ENDFOR
		ENDELSE
	ENDIF
;
;  Convert the date/time into the number of seconds since midnight 1 January
;  1958.
;
	IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
	RETURN, SECONDS + (UT.MJD - 36204) * 60.D0^2 * 24.D0
;
;
;  Error handling point.
;
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) EQ 0 THEN MESSAGE, MESSAGE
	ERRMSG = MESSAGE
	RETURN, -1
;
	END
