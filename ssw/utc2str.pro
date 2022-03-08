	FUNCTION UTC2STR, UTC, ECS=ECS, VMS=VMS, STIME=STIME,	$
		TRUNCATE=TRUNCATE, DATE_ONLY=DATE_ONLY, TIME_ONLY=TIME_ONLY, $
		UPPERCASE=UPPERCASE,ERRMSG=ERRMSG,NOZ=K_NOZ, DOY=DOY
;+
; Project     :	SOHO - CDS
;
; Name        :	UTC2STR()
;
; Purpose     :	Converts CDS external time in UTC to string format.
;
; Explanation :	This procedure takes the UTC time in "internal" or "external"
;		format, and converts it to a calendar string.  The default
;		format is the Consultative Committee on Space Data Systems
;		(CCSDS) ASCII Calendar Segmented Time Code format (ISO 8601),
;		but other formats are also supported.  For notes on various 
;		time formats, see file aaareadme.txt.
;
; Use         :	Result = UTC2STR( UTC )
;		Result = UTC2STR( UTC, /ECS )
;
; Inputs      :	UTC	= The UTC date/time as a data structure with the
;			  elements YEAR, MONTH, DAY, HOUR, MINUTE, SECOND,
;			  and MILLISECOND.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function will be an ASCII string containing
;		the UTC time to millisecond accuracy in CCSDS format, e.g.
;
;			"1988-01-18T17:20:43.123Z"
;
;		However, if the ECS keyword is set, then the following format
;		will be used instead.
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
; Keywords    :	ECS	  = If set, then the output will be in ECS format, as
;			    described above.
;
;		VMS	  = If set, then the output will be in VMS format, as
;			    described above.
;
;		STIME	  = If set, then the output will be in STIME format, as
;			    described above.
;
;		DOY	  = Return with DOY format like
;
;			"1988:018 17:20:43.123"
;
;		Only one of the above keywords can be set.  If none of them are
;		set, then the output is in CCSDS format.
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
;			    keywords.  NOZ=1 is now the default.
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
;				RESULT = UTC2STR( UTC, ERRMSG=ERRMSG )
;				IF ERRMSG NE '' THEN ...
;
; Calls       :	DATATYPE, TAG_EXIST
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	If an error is encountered and the ERRMSG keyword is set, 
;		UTC2STR returns an string scalar equal to '-1'.
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
;		Version 2, William Thompson, GSFC, 21 October 1993.
;			Modified to overcome IDL formatted string limitation
;			when processing more than 1024 values, based in part on
;			a suggestion by Mark Hadfield, NIWA Oceanographic.
;		Version 3, William Thompson, GSFC, 20 December 1994
;			Added keywords TRUNCATE, DATE_ONLY, TIME_ONLY
;		Version 4, Donald G. Luttermoser, GSFC/ARC, 3 January 1995
;			Added the keyword ERRMSG.
;		Version 5, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG to the internally called procedures.
;			Made the error handling routine more robust.  Note 
;			that this routine can handle both scalars and vectors
;			as input.
;		Version 6, William Thompson, GSFC, 14 March 1995
;			Added keywords VMS, STIME, UPPERCASE
;               Version 7  CDP, RAL  15-Mar-95.  Fixed typo in Version 6
;		Version 8, William Thompson, GSFC, 17 September 1997
;			Added keyword NOZ.
;		Version 9, 07-Feb-2000, William Thompson, GSFC
;			Once again overcome 1024 value limitation.
;               Version 10, 09-Jul-2003, William Thompson, GSFC
;                       Make /NOZ the default.
;               Version 11, William Thompson, GSFC, 25-Oct-2005
;                       Interpret any structure with tags MJD and TIME as CDS
;                       internal time.
;               Version 12, Kim Tolbert, 13-Jan-2014, Change () to [] to avoid
;                       confusion with DATE routine.
;		Version 13, Nathan Rich, NRL, 12 Aug 2020
;			Add /DOY
;
; Version     :	Version 13, 12-Aug-2020
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Determine the value of NOZ.
;
        IF N_ELEMENTS(K_NOZ) EQ 1 THEN NOZ = K_NOZ ELSE NOZ = 1
;
;  Check the input array.
;
	IF N_PARAMS() NE 1 THEN BEGIN
		MESSAGE = 'Syntax:  Result = UTC2STR( UTC )'
		GOTO, HANDLE_ERROR
	ENDIF
;
	IF DATATYPE(UTC,1) NE 'Structure' THEN BEGIN
		MESSAGE = 'UTC must be a structure variable.'
	ENDIF ELSE BEGIN
            IF TAG_EXIST(UTC,'mjd',/TOP_LEVEL) AND $
              TAG_EXIST(UTC,'time',/TOP_LEVEL) THEN $
              UT = INT2UTC(UTC,ERRMSG=MESSAGE) ELSE UT = UTC
	ENDELSE
	IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
;
;  If the number of date values exceeds 1024, then call this routine
;  recursively until all the dates are processed.
;
	N_UTC = N_ELEMENTS(UTC)
	IF N_UTC GT 1024 THEN BEGIN
	    I1 = 0
	    DATE = STRARR(N_UTC)
	    WHILE I1 LT N_UTC DO BEGIN
		I2 = (I1 + 1023) < (N_UTC - 1)
		MESSAGE = ''
		DATE[I1:I2] = UTC2STR(UTC[I1:I2], ECS=ECS, VMS=VMS,	$
			STIME=STIME, TRUNCATE=TRUNCATE, DATE_ONLY=DATE_ONLY, $
			TIME_ONLY=TIME_ONLY, UPPERCASE=UPPERCASE,	$
			ERRMSG=MESSAGE, NOZ=NOZ, DOY=DOY)
		IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
		I1 = I2 + 1
	    ENDWHILE
	    GOTO, REFORM
	ENDIF
;
;  Decide how to format the character string.
;
	IF KEYWORD_SET(VMS) OR KEYWORD_SET(STIME) THEN BEGIN
		S1 = '-'	;Between date parts
		S2 = ' '	;Between date and time part
		S3 = ''		;After time part
	END ELSE IF KEYWORD_SET(ECS) THEN BEGIN
		S1 = '/'
		S2 = ' '
		S3 = ''
	END ELSE BEGIN
		S1 = '-'
		S2 = 'T'
		IF KEYWORD_SET(NOZ) THEN S3 = '' ELSE S3 = 'Z'
	ENDELSE
;
;  Format the date into a character string.
;
	IF KEYWORD_SET(VMS) OR KEYWORD_SET(STIME) THEN BEGIN
		MONTH = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug', $
			'Sep','Oct','Nov','Dec']
		IF KEYWORD_SET(UPPERCASE) THEN MONTH = STRUPCASE(MONTH)
		DATE =	STRING(UT.DAY, FORMAT='(I2)') + S1 +	$
			MONTH(UT.MONTH-1) + S1 +		$
			STRMID(STRTRIM(10000+UT.YEAR,2),1,4)
	ENDIF ELSE IF KEYWORD_SET(DOY) THEN BEGIN
		dayn = utc2doy(utc)
		DATE =	STRMID(STRTRIM(10000+UT.YEAR,2),1,4) + ":"  +	$
			string(dayn,'(i03)')
		S2 = ' '
	ENDIF ELSE BEGIN
		DATE =	STRMID(STRTRIM(10000+UT.YEAR,2),1,4) + S1  +	$
			STRMID(STRTRIM(100+UT.MONTH ,2),1,2) + S1  +	$
			STRMID(STRTRIM(100+UT.DAY   ,2),1,2)
	ENDELSE
;
;  Format the time into a character string.
;
	TIME =	STRMID(STRTRIM(100+UT.HOUR  ,2),1,2) + ':' +	$
		STRMID(STRTRIM(100+UT.MINUTE,2),1,2) + ':' +	$
		STRMID(STRTRIM(100+UT.SECOND,2),1,2)
;
;  If the TRUNCATE keyword was not set, then add in the milliseconds
;  contribution.  However, if the STIME keyword was set, then only add in the
;  first two digits.
;
	IF NOT KEYWORD_SET(TRUNCATE) THEN BEGIN
		IF KEYWORD_SET(STIME) THEN N_CHARS=2 ELSE N_CHARS=3
		TIME = TIME + '.' +	$
			STRMID(STRTRIM(1000+UT.MILLISECOND,2),1,N_CHARS)
	ENDIF
	TIME = TIME + S3
;
;  If DATE_ONLY or TIME_ONLY were set, then extract the relevant part of the
;  character string.
;
	IF KEYWORD_SET(TIME_ONLY) THEN BEGIN
		DATE = TIME
	END ELSE IF NOT KEYWORD_SET(DATE_ONLY) THEN BEGIN
		DATE = DATE + S2 + TIME
	ENDIF
;
;  If the original date was a simple scalar, then the CCSDS date should be a
;  scalar.  Otherwise, the date should have the same dimensionality as the
;  input UTC.
;
REFORM:
	SZ = SIZE(UTC)
	IF N_ELEMENTS(UTC) GT 1 THEN DATE = REFORM(DATE,SZ[1:SZ(0)])
;
	IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
	RETURN, DATE
;
;  Error handling point.
;
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) EQ 0 THEN MESSAGE, MESSAGE
	ERRMSG = MESSAGE
	RETURN, '-1'
;
	END
