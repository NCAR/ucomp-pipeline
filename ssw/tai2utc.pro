	FUNCTION TAI2UTC, TAI, EXTERNAL=EXTERNAL, CCSDS=CCSDS, ECS=ECS,	$
		VMS=VMS, STIME=STIME, TRUNCATE=TRUNCATE, DATE_ONLY=DATE_ONLY, $
		TIME_ONLY=TIME_ONLY, UPPERCASE=UPPERCASE, NOZ=NOZ,	$
		NOCORRECT=NOCORRECT, ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	TAI2UTC()
;
; Purpose     :	Converts TAI time in seconds to UTC calendar time.
;
; Explanation :	This procedure takes the Atomic International Time (TAI)
;		calculated from the 6 byte (local) on-board time from the
;		spacecraft and converts it into UTC calendar time in one of the
;		CDS standard formats -- for acceptable formats see file 
;               aaareadme.txt.
;
; Use         :	Result = TAI2UTC( TAI )
;		Result = TAI2UTC( TAI, /EXTERNAL )
;		Result = TAI2UTC( TAI, /CCSDS )
;		Result = TAI2UTC( TAI, /ECS )
;
; Inputs      :	TAI	= The time in seconds from midnight, 1 January 1958.
;			  This should be a double precision array.  Any
;			  necessary calibrations should be applied before
;			  calling this routine.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function will be the UTC calendar time in one
;		of several formats, depending on the keywords passed.
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
;				   See UTC2STR for more information.
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
;		VMS	 = If set, then the output will be in VMS format, as
;			   described above.
;
;		STIME	 = If set, then the output will be in STIME format, as
;			   described above.
;
;               NOCORRECT = If set, then the time will be assumed to be already
;			    a UTC value, even though apparently in TAI format,
;			    and no adjustment will be made for leap seconds.
;
;                           This keyword can also be used to convert to a TAI
;                           time in a UTC-formatted format.
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
;		ERRMSG	 = If defined and passed, then any error messages 
;			   will be returned to the user in this parameter 
;			   rather than being handled by the IDL MESSAGE 
;			   utility.  If no errors are encountered, then a null 
;			   string is returned.  In order to use this feature, 
;			   the string ERRMSG must be defined first, e.g.,
;
;				ERRMSG = ''
;				RESULT = TAI2UTC( TAI, ERRMSG=ERRMSG )
;				IF ERRMSG NE '' THEN ...
;
; Calls       :	DATATYPE, GET_LEAP_SEC, INT2UTC
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
; Side effects:	The result of an array with a single element may be a scalar.
;               If an error has been encountered and the ERRMSG keyword has
;		been set, TAI2UTC returns an integer value of -1.
;
; Category    :	Utilities, Time.
;
; Prev. Hist. :	None.  However, the concept of "internal" and "external" time
;		is based in part on the Yohkoh software by M. Morrison and G.
;		Linford, LPARL.
;
; Written     :	William Thompson, GSFC, 12 September 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 21 September 1993.
;		Version 2, William Thompson, GSFC, 14 November 1994
;			Changed .DAY to .MJD
;		Version 3, William Thompson, GSFC, 20 December 1994
;			Added keywords TRUNCATE, DATE_ONLY, TIME_ONLY
;		Version 4, Donald G. Luttermoser, GSFC/ARC, 28 December 1994
;			Added the keyword ERRMSG.
;		Version 5, William Thompson, GSFC, 25 January 1995
;			Changed to call intrinsic ROUND instead of NINT.  The
;			version of NINT in the Astronomy User's Library doesn't
;			automatically select between short and long integers as
;			the CDS version does.
;		Version 6, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG keyword to internally called procedures.
;			Made error handling procedure more robust.  Note
;			that this routine can handle both scalars and vectors
;			as input.
;		Version 7, William Thompson, GSFC, 14 March 1995
;			Added keywords VMS, STIME, UPPERCASE
;		Version 8, William Thompson, GSFC, 28 January 1997
;			Allow for long input arrays.
;               Version 9, William Thompson, GSFC, 8-Sep-2004
;                       Added keyword NOCORRECT
;               Version 10, William Thompson, GSFC, 26-Sep-2006
;                       Add call to CHECK_INT_TIME to correct round-off errors
;
; Version     :	Version 10, 26-Sep-2006
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Check the input array.
;
	IF N_PARAMS() NE 1 THEN BEGIN
		MESSAGE = 'Syntax:  Result = TAI2UTC( TAI )'
	ENDIF ELSE BEGIN
		IF DATATYPE(TAI,1) NE 'Double' THEN MESSAGE =	$
			'TAI must be double precision.'
	ENDELSE
	IF MESSAGE NE '' THEN GOTO,HANDLE_ERROR
;
;  Calculate the number of days the input time represents, and calculate the
;  Modified Julian Day number for that day.  Also calculate the number of
;  seconds since the start of the day.
;
	DAYSECONDS = 60.D0^2 * 24.D0	;No. of seconds in a day.
	MJD = LONG(36204 + TAI / DAYSECONDS)
	SECONDS = TAI - (MJD - 36204) * DAYSECONDS
;
;  Correct the time for leap seconds added since 1 January 1958.  Start off
;  with a total of 9 seconds offset just prior to 1 January 1972.  Before that
;  date, a more complicated algorithm was used to determine the difference
;  between TAI and UTC.
;
        IF NOT KEYWORD_SET(NOCORRECT) THEN BEGIN
            SECONDS = SECONDS - 9.D0
            W = WHERE(SECONDS LT 0, NCOUNT)
            IF NCOUNT GT 0 THEN BEGIN
                MJD(W) = MJD(W) - 1
                SECONDS(W) = SECONDS(W) + DAYSECONDS
            ENDIF
;
;  Call GET_LEAP_SEC to return an array containing the dates that leap seconds
;  were inserted.  Correct the times for each leap second.  Take into account
;  the fact that this might change the date to the previous day.  Also take
;  into account the fact that the time being considered may in fact be a leap
;  second.
;
            GET_LEAP_SEC, MJD0, ERRMSG=ERRMSG
            IF N_ELEMENTS(ERRMSG) NE 0 THEN $
              IF ERRMSG(0) NE '' THEN RETURN, -1
            FOR I = 0L,N_ELEMENTS(MJD0)-1 DO BEGIN
                W = WHERE(MJD GT MJD0(I), NCOUNT)
                IF NCOUNT GT 0 THEN SECONDS(W) = SECONDS(W) - 1
                W = WHERE(SECONDS LT 0, NCOUNT)
                IF NCOUNT GT 0 THEN BEGIN
                    MJD(W) = MJD(W) - 1
                    SECONDS(W) = SECONDS(W) + DAYSECONDS +	$
				(MJD(W) EQ MJD0(I))
                ENDIF
            ENDFOR
        ENDIF
;
;  Form a structure out of the Modified Julian Date and the time in seconds.
;
	DATE = {CDS_INT_TIME, MJD: 0L, TIME: 0L}
	IF N_ELEMENTS(TAI) GT 1 THEN BEGIN
		DATE = REPLICATE(DATE, N_ELEMENTS(TAI))
		SZ = SIZE(TAI)
		DATE = REFORM(DATE,SZ(1:SZ(0)))
	END ELSE BEGIN
		MJD = MJD(0)
		SECONDS = SECONDS(0)
	ENDELSE
	DATE.MJD = MJD
	DATE.TIME = ROUND(1000*SECONDS)
;
;  Correct possible round-off error at end-of-day.
;
        IF MAX(DATE.TIME) GE 86400000L THEN CHECK_INT_TIME, DATE
;
;  If one of the optional formats was selected, then call INT2UTC to convert
;  the format.
;
	IF KEYWORD_SET(EXTERNAL) OR KEYWORD_SET(CCSDS) OR KEYWORD_SET(ECS) OR $
			KEYWORD_SET(VMS) OR KEYWORD_SET(STIME) THEN BEGIN
		DATE = INT2UTC(DATE, CCSDS=CCSDS, ECS=ECS, VMS=VMS,	$
			STIME=STIME, TRUNCATE=TRUNCATE, DATE_ONLY=DATE_ONLY, $
			TIME_ONLY=TIME_ONLY, UPPERCASE=UPPERCASE,	$
			NOZ=NOZ,ERRMSG=ERRMSG)
		IF N_ELEMENTS(ERRMSG) NE 0 THEN $
			IF ERRMSG(0) NE '' THEN RETURN, -1
	ENDIF
;
;  Return the UTC date/time.
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
