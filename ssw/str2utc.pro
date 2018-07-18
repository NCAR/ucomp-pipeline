	FUNCTION STR2UTC, UTC, EXTERNAL=EXTERNAL, DMY=DMY, MDY=MDY, YMD=YMD, $
		TEMPLATE=K_TEMPLATE, ERRMSG=ERRMSG
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
;			  the format used by the SOHO ECS.  (Another optional
;			  format, as used at Wilcox observatory, is to replace
;			  the "T" with an underscore "_", and the dashes with
;			  periods.)
;
;			  In addition this routine can parse dates where only
;			  two digits of the year is given--the year is assumed
;			  to be between 1950 and 2049.
;
;			  Character string months, e.g. "JAN" or "January", can
;			  be used instead of the number.  In that case, it
;			  assumes that the date is either in day-month-year or
;			  month-day-year format, e.g. "18-JAN-1988" or
;			  "Jan-18-1988".  However, if the first parameter is
;			  four digits, then year-month-day is assumed, e.g.
;			  "1988-Jan-18".
;
;			  Dates in a different order than year-month-day are
;			  supported, but unless the month is given as a
;			  character string, then these are only supported
;			  through the /MDY and /DMY keywords.
;
;                         One last variation which is now supported is strings
;                         as used in filenames, e.g. "20070927_041636" or
;                         "20070927".  Only those two variations are supported.
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
;
;		DMY	 = Normally the date is in the order year-month-day.
;			   However, if DMY is set then the order is
;			   day-month-year.  Note that if the month is given as
;			   a character string, then the default is
;			   day-month-year.
;
;		MDY	 = If set, then the date is in the order
;			   month-day-year.
;
;		YMD	 = If set, then the date is in the order
;			   year-month-day.
;
;		TEMPLATE = If set, then the first string in the input array UTC
;			   is used as a template for all the strings to follow.
;			   This speeds up processing of large string arrays.
;			   However, it requires that all the strings have
;			   *EXACTLY* the same format.  In other words, all the
;			   date fields must be in exactly the same places, with
;			   exactly the same widths.
;
;			   If the TEMPLATE keyword is not passed, then the
;			   software tries to automatically determine the
;			   correct setting, based on the positions of separator
;			   characters, and the total length of the string.  If
;			   these match for all the strings, then TEMPLATE is
;			   automatically set to 1.  Use TEMPLATE=0 to override.
;
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
; Calls       :	DATATYPE, DATE2MJD, UTC2INT, MJD2DATE, VALID_NUM, BOOST_ARRAY
;
; Common      :	None.
;
; Restrictions:	The components of the time should be separated by the colon ":"
;		character, except between the seconds and fractional seconds
;		parts, where the separator is the period "." character.  As of
;		version 21, the colon separator can be omitted, but this is not
;		recommended.
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
;		In this case, the date would be converted to "1993-March-3".
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
;		Version 11, William Thompson, GSFC, 15 June 1995
;			Modified so that the default behavior is different when
;			the month is given as a character string.  In that
;			case, it now assumes that the year is the *last*
;			parameter in the string unless given with all four
;			digits.
;		Version 12, William Thompson, GSFC, 19 June 1995
;			Made logic used in version 11 more robust.  Added
;			keyword YMD.
;		Version 13, William Thompson, GSFC, 6 October 1995
;			Added ability to recognize strings that end in either
;			AM or PM.
;		Version 14, William Thompson, GSFC, 15 January 1996
;			Extended bug fix of version 10 to "SEPT" and "AUGUST".
;		Version 15, Dominic Zarro, GSFC, 15 January 1997
;			Included input UTC string in output error message
;		Version 16, William Thompson, GSFC, 27 January 1997
;			Include support for Wilcox/MDI time format, e.g.
;			"1988.01.18_17:20"
;		Version 17, William Thompson, GSFC, 28 January 1997
;			Allow for long input arrays.
;		Version 18, William Thompson, GSFC, 7 February 1997
;			Further refined support for Wilcox/MDI time format,
;			allowing the string to end in _TAI or _UT.
;		Version 19, William Thompson, GSFC, 30 September 1997
;			Fixed bug involving times before dates, and month
;			strings containing the letter T.
;		Version 20, William Thompson, GSFC, 8 June 1999
;			Avoid conflict with date.pro
;		Version 21, 07-Apr-2000, William Thompson, GSFC
;			Allow ":" to be omitted in time string.
;			Call CHECK_EXT_TIME
;		Version 22, 10-Apr-2000, William Thompson, GSFC
;			Added keyword TEMPLATE
;		Version 23, 28-Apr-2000, William Thompson, GSFC
;			Fixed bug with /TEMPLATE and only dates, no times.
;               Version 24, 30-Apr-2000, S.L.Freeland, LMSAL
;                       Made backwardly compatible with Version < 5
;                       Scalarize 1 element DAY/MONTH/YEAR 	  
;		Version 25, 1-May-2000, William Thompson, GSFC
;			Corrected scalarization of YEAR/MONTH/DAY
;		Version 26, 30-Jun-2000, William Thompson, GSFC
;			Fixed bug with only hours, no minutes or seconds.
;		Version 27, 05-Jul-2000, William Thompson, GSFC
;			If no date passed, then use today.
;               Version 28, 04-Aug-2004, William Thompson, GSFC
;                       Test for too many colons.
;               Version 29, 09-Aug-2005, William Thompson, GSFC
;                       Automatic test for TEMPLATE setting
;               Version 30, 06-Dec-2005, William Thompson, GSFC
;                       Catch case with TEMPLATE when some strings start with a
;                       blank, e.g. " 1-Nov-2005"
;               Version 31, 27-Sep-2007, William Thompson, GSFC
;                       Catch filename-style dates, e.g. "20070927_041636"
;
; Version     :	Version 31, 27-Sep-2007
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
	RSLT = {CDS_EXT_TIME,	$
		YEAR:	0,	$
		MONTH:	0,	$
		DAY:	0,	$
		HOUR:	0,	$
		MINUTE:	0,	$
		SECOND:	0,	$
		MILLISECOND: 0}
;
;  Make a copy of UTC which can be manipulated.  Strip off any leading or
;  trailing blanks.
;
        UT = STRTRIM(UTC,2)
;
;  Catch the case where the date starts with a single-digit day.
;
        CHAR1 = STRMID(UT,0,1)
        CHAR2 = STRMID(UT,1,1)
        W = WHERE((CHAR1 GE '0') AND (CHAR1 LE '9') AND $
                  ((CHAR2 EQ '-') OR (CHAR2 EQ '/')), COUNT)
        IF COUNT GT 0 THEN UT[W] = '0' + UT[W]
;
;  If UTC is an array, then call this routine recursively to interpret each
;  element individually.
;
	SZ = SIZE(UT)
	IF SZ[0] GE 1 THEN BEGIN
	    RSLT = REPLICATE(RSLT, N_ELEMENTS(UT))
	    LEN = STRLEN(UT)
	    LMIN = MIN(LEN,MAX=LMAX)
;
;  Set the default value of TEMPLATE, before testing whether the default can be
;  used.
;
            IF N_ELEMENTS(K_TEMPLATE) EQ 1 THEN TEMPLATE = K_TEMPLATE ELSE $
              TEMPLATE = 1
            IF TEMPLATE THEN BEGIN
;
;  If some strings are just one character longer than other strings, see if
;  the extra character is 'Z'.  If not, set TEMPLATE=0.
;
                IF LMAX EQ (LMIN+1) THEN BEGIN
                    W = WHERE(LEN EQ LMAX)
                    CHAR = STRUPCASE(STRMID(UT[W],LMIN,1))
                    W = WHERE(CHAR NE 'Z', COUNT)
                    IF COUNT GT 0 THEN TEMPLATE = 0
                END ELSE IF LMAX NE LMIN THEN TEMPLATE = 0
;
;  Look for separator characters, and see if they match in all strings.
;
                SEPS = ['-','/','_','.',':',' ']
                FOR I_SEP = 0,N_ELEMENTS(SEPS)-1 DO BEGIN
                    IPOS = 0
                    WHILE TEMPLATE AND (IPOS GE 0) DO BEGIN
                        IPOS = STRPOS(UT[0], SEPS[I_SEP], IPOS)
                        IF IPOS GE 0 THEN BEGIN
                            CHAR = STRMID(UT,IPOS,1)
                            W = WHERE(CHAR NE SEPS[I_SEP], COUNT)
                            IF COUNT GT 0 THEN TEMPLATE = 0
                            IPOS = IPOS + 1
                        ENDIF
                    ENDWHILE
                ENDFOR
            ENDIF
;
;  If the TEMPLATE keyword was set, and all the strings in the array have the
;  same length, then skip this step, and treat all the strings below based on
;  the format of the first string.
;
	    IF NOT TEMPLATE THEN BEGIN
		FOR I=0L,N_ELEMENTS(UT)-1 DO BEGIN
		    DT = STR2UTC(UT(I), /EXTERNAL, DMY=DMY, MDY=MDY, $
			    YMD=YMD, ERRMSG=ERRMSG)
		    IF N_ELEMENTS(ERRMSG) NE 0 THEN	$
			    IF ERRMSG[0] NE '' THEN RETURN, -1
		    RSLT(I).YEAR   = DT.YEAR
		    RSLT(I).MONTH  = DT.MONTH
		    RSLT(I).DAY    = DT.DAY
		    RSLT(I).HOUR   = DT.HOUR
		    RSLT(I).MINUTE = DT.MINUTE
		    RSLT(I).SECOND = DT.SECOND
		    RSLT(I).MILLISECOND = DT.MILLISECOND
		ENDFOR
		RSLT = REFORM(RSLT, SZ(1:SZ[0]), /OVERWRITE)
		GOTO, FINISH
	    ENDIF
        ENDIF
;
;  Catch strings of the format "yyyymmdd" or "yyyymmdd_hhmmss", and reformat
;  into a more standard format.
;
        IF (STRLEN(UT[0]) EQ 8) AND VALID_NUM(UT[0]) THEN UT = $
          STRMID(UT,0,4) + '-' + STRMID(UT,4,2) + '-' + STRMID(UT,6,2)
        IF (STRLEN(UT[0]) EQ 15) AND VALID_NUM(STRMID(UT[0],0,8)) AND $
          (STRMID(UT[0],8,1) EQ '_') AND VALID_NUM(STRMID(UT[0],9,6)) THEN $
          UT = STRMID(UT,0,4) + '-' + STRMID(UT,4,2) + '-' + STRMID(UT,6,2) + $
          'T' + STRMID(UT,9,2) + ':' + STRMID(UT,11,2) + ':' + STRMID(UT,13,2)
;
;  Look for the letters AM or PM at the end of the string, and strip them off
;  if there.
;
	UT = STRUPCASE(UT)
	IF N_ELEMENTS(UT) GT 1 THEN UT = REFORM(UT,N_ELEMENTS(UT),/OVERWRITE)
	AMPM_TEST = STRMID(UT,STRLEN(UT[0])-2,2)
	IF (AMPM_TEST[0] EQ 'AM') OR (AMPM_TEST[0] EQ 'PM') THEN	$
		UT = STRMID(UT,0,STRLEN(UT[0])-2)
;
;  Look for the letters UT, UTC, or TAI at that end of the string, and strip
;  them off.  If TAI appears, then save that information for later.
;
	TAI_TIME = 0
	UT_TEST = STRPOS(UT[0],'UT')
	IF UT_TEST GT 0 THEN UT = STRMID(UT,0,UT_TEST) ELSE BEGIN
	    TAI_TEST = STRPOS(UT[0],'TAI')
	    IF TAI_TEST GT 0 THEN BEGIN
		TAI_TIME = 1
		UT = STRMID(UT,0,TAI_TEST)
	    ENDIF
	ENDELSE
;
;  If the string ends in an underscore, then strip it off.
;
	IF STRMID(UT[0],STRLEN(UT[0])-1,1) EQ '_' THEN	$
		UT = STRMID(UT,0,STRLEN(UT[0])-1)
;
;  Separate the input string into the date and time parts.  Make sure not to
;  confuse the "T" in "OCT", "SEPT", or "AUGUST" for the separator between the
;  date and time parts in a CCSDS formatted string.
;
	START = STRPOS(UT[0],'OCT')
	IF START GE 0 THEN START = START + 3 ELSE BEGIN
	    START = STRPOS(UT[0],'SEPT')
	    IF START GE 0 THEN START = START + 4 ELSE BEGIN
		START = STRPOS(UT[0],'AUGUST')
		IF START GE 0 THEN START = START + 6 ELSE START = 0
	    ENDELSE
	ENDELSE
	COLON = STRPOS(UT[0],':')
	IF COLON LT 0 THEN COLON = STRLEN(UT[0])
	IF START LT COLON THEN BEGIN
	    SEP = STRPOS(UT[0],'T',START) > STRPOS(UT[0],' ',START) >	$
		    STRPOS(UT[0],'_',START)
	END ELSE BEGIN
	    TEMP = STRMID(UT[0],0,START-1)
	    SEP = STRPOS(TEMP,'T') > STRPOS(TEMP,' ') > STRPOS(TEMP,'_')
	ENDELSE
	IF SEP LT 0 THEN BEGIN
	    DTSEP = STRPOS(UT[0],'-') > STRPOS(UT[0],'/') > STRPOS(UT[0],'.')
	    IF DTSEP GE 0 THEN BEGIN
		DT = UT
		TIME = ''
	    END ELSE BEGIN
		DT = ''
		TIME = UT
	    ENDELSE
	END ELSE BEGIN
	    DT = STRMID(UT,0,SEP)
	    TIME = STRTRIM(STRMID(UT,SEP+1,STRLEN(UT[0])-SEP-1),2)
	ENDELSE
;
;  If the date contains the colon ":" character, or the time contains a date
;  separator, then the date and time are reversed.
;
	IF (STRPOS(DT[0],':') GE 0) OR (STRPOS(TIME[0],'-') GE 0) OR	$
		(STRPOS(TIME[0],'/') GE 0) THEN BEGIN
	    TEMP = DT
	    DT = TIME
	    TIME = TEMP
	ENDIF
;
;  Decide whether or not the date is given as year, month, day or as year,
;  day-of-year.  If the latter, calculate the month and day from the Modified
;  Julian Day number.
;
	IF STRPOS(DT[0],'-') GE 0 THEN BEGIN
	    DTSEP = '-'
	END ELSE IF STRPOS(DT[0],'/') GE 0 THEN BEGIN
	    DTSEP='/'
	END ELSE DTSEP='.'
	DELVARX,TEMP
	POS = STRPOS(DT[0],DTSEP)
	WHILE POS GT 0 DO BEGIN
	    BOOST_ARRAY, TEMP, STRMID(DT,0,POS)
	    DT = STRMID(DT,POS+1,STRLEN(DT[0])-POS-1)
	    POS = STRPOS(DT[0],DTSEP)
	ENDWHILE
	BOOST_ARRAY, TEMP, DT
	IF N_ELEMENTS(TEMP) GT 1 THEN DT = TRANSPOSE(TEMPORARY(TEMP))
;
;  Day-of-year variation.
;
	IF N_ELEMENTS(DT[*,0]) EQ 2 THEN BEGIN
	    IF NOT (VALID_NUM(DT[0]) AND VALID_NUM(DT[1])) THEN BEGIN
		MESSAGE ='Unrecognizable date format - Year/DOY variation.'
		GOTO, HANDLE_ERROR
	    ENDIF
	    YEAR = REFORM(FIX(DT[0,*]))
	    DOY  = REFORM(FIX(DT[1,*]))
	    IF DOY[0] GE 1000 THEN BEGIN
		TEMP = YEAR
		YEAR = DOY
		DOY  = TEMPORARY(TEMP)
	    ENDIF
;
;  If the year is only two digits, then assume that the year is between 1950
;  and 2049.
;
	    IF YEAR[0] LT 100 THEN YEAR = ((YEAR + 50) MOD 100) + 1950
	    MJD = DATE2MJD(YEAR,DOY,ERRMSG=ERRMSG)
	    IF N_ELEMENTS(ERRMSG) NE 0 THEN	$
		    IF ERRMSG[0] NE '' THEN RETURN, -1
	    MJD2DATE,MJD,YEAR,MONTH,DAY,ERRMSG=ERRMSG
	    IF N_ELEMENTS(ERRMSG) NE 0 THEN	$
		    IF ERRMSG[0] NE '' THEN RETURN, -1
;
;  Year, month, and day variation.  First select out the three components
;  depending on the settings of the keywords.
;
	END ELSE IF N_ELEMENTS(DT[*,0]) EQ 3 THEN BEGIN
	    IF KEYWORD_SET(DMY) THEN BEGIN
		YEAR  = REFORM(DT[2,*])
		MONTH = REFORM(DT[1,*])
		DAY   = REFORM(DT[0,*])
	    END ELSE IF KEYWORD_SET(MDY) THEN BEGIN
		YEAR  = REFORM(DT[2,*])
		MONTH = REFORM(DT[0,*])
		DAY   = REFORM(DT[1,*])
	    END ELSE IF KEYWORD_SET(YMD) THEN BEGIN
		YEAR  = REFORM(DT[0,*])
		MONTH = REFORM(DT[1,*])
		DAY   = REFORM(DT[2,*])
	    END ELSE BEGIN
		YEAR  = REFORM(DT[0,*])
		MONTH = REFORM(DT[1,*])
		DAY   = REFORM(DT[2,*])
;
;  If the year field is two digits or less, and the month field has three or
;  more characters, then assume that the VMS-style variation (DD-MMM-YYYY) is
;  being used.
;
		IF (STRLEN(YEAR[0]) LE 2) AND (STRLEN(MONTH[0]) GE 3) $
			THEN BEGIN
		    TEMP = YEAR
		    YEAR = DAY
		    DAY = TEMPORARY(TEMP)
;
;  Or if the year field is not an integer, then assume the date is in
;  MMM-DD-YYYY format.
;
		END ELSE IF NOT VALID_NUM(YEAR[0]) THEN BEGIN
		    TEMP = YEAR
		    YEAR = DAY
		    DAY  = MONTH
		    MONTH = TEMPORARY(TEMP)
		ENDIF
	    ENDELSE
;
;  Convert the day to a number.
;
	    IF NOT VALID_NUM(DAY[0]) THEN BEGIN
		MESSAGE = 'Unrecognizable date format - day.'
		GOTO, HANDLE_ERROR
	    END ELSE DAY = FIX(DAY)
;
;  If the year is only two digits, then assume that the year is between 1950
;  and 2049.
;
	    IF NOT VALID_NUM(YEAR[0]) THEN BEGIN
		MESSAGE = 'Unrecognizable date format - year.'
		GOTO, HANDLE_ERROR
	    END ELSE YEAR = FIX(YEAR)
	    IF YEAR[0] LT 100 THEN YEAR = ((YEAR + 50) MOD 100) + 1950
;
;  If the month is not a number, then assume that it is a month string.
;
	    IF NOT VALID_NUM(MONTH[0]) THEN BEGIN
		MONTH = STRUPCASE(STRMID(MONTH,0,3))
		IF N_ELEMENTS(MONTH) GT 1 THEN BEGIN
		    TEMP = INTARR(N_ELEMENTS(MONTH))
		    FOR I=0,11 DO BEGIN
			W = WHERE(MONTH EQ MONTHS(I), COUNT)
			IF COUNT GT 0 THEN TEMP(W) = I+1
		    ENDFOR
		    MONTH = TEMPORARY(TEMP)
		END ELSE MONTH = (WHERE(MONTH[0] EQ MONTHS) + 1)[0]
		IF MONTH[0] EQ 0 THEN BEGIN
		    MESSAGE = 'Unrecognizable date format - month.'
		    GOTO, HANDLE_ERROR
		ENDIF
	    END ELSE MONTH = FIX(MONTH)
;
;  No date.
;
	END ELSE IF TOTAL(STRLEN(DT)) EQ 0 THEN BEGIN
	    GET_UTC, TODAY, /EXTERNAL
	    YEAR = TODAY.YEAR
	    MONTH = TODAY.MONTH
	    DAY = TODAY.DAY
	END ELSE BEGIN
	    MESSAGE = 'Unrecognizable date format '
	    GOTO, HANDLE_ERROR
	ENDELSE
;
;  Parse the time.  First remove any trailing Z characters.
;
	Z = STRPOS(TIME[0],'Z')
	IF Z GT 0 THEN TIME = STRMID(TIME,0,Z)
	TM = STRARR(3,N_ELEMENTS(TIME))
	DELVARX,TEMP
	POS = STRPOS(TIME[0],':')
	IF POS LT 0 THEN POS = STRLEN(TIME[0])
	WHILE POS GT 0 DO BEGIN
	    BOOST_ARRAY, TEMP, STRMID(TIME,0,POS)
	    TIME = STRMID(TIME,POS+1,STRLEN(TIME[0])-POS-1)
	    POS = STRPOS(TIME[0],':')
	ENDWHILE
	BOOST_ARRAY, TEMP, TIME
	IF N_ELEMENTS(TEMP) GT 1 THEN BEGIN
            TEMP = TRANSPOSE(TEMPORARY(TEMP))
;
;  Test for too many colons.
;
            SZT = SIZE(TEMP)
            IF (SZT[0] GT 0) AND (SZT[1] GT 3) THEN BEGIN
                MESSAGE = 'Unrecognizable date format - second.'
                GOTO, HANDLE_ERROR
            ENDIF
            TM(0,0) = TEMP
        ENDIF
;
	IF (STRLEN(TM[0]) GT 0) AND NOT VALID_NUM(TM[0]) THEN BEGIN
	    MESSAGE = 'Unrecognizable date format - hour.'
	    GOTO, HANDLE_ERROR
	END ELSE HOUR = DOUBLE(REFORM(TM(0,*)))
	IF (STRLEN(TM[1]) GT 0) AND NOT VALID_NUM(TM[1]) THEN BEGIN
	    MESSAGE = 'Unrecognizable date format - minute.'
	    GOTO, HANDLE_ERROR
	END ELSE MINUTE = FIX(REFORM(TM(1,*)))
	IF (STRLEN(TM[2]) GT 0) AND NOT VALID_NUM(TM[2]) THEN BEGIN
	    MESSAGE = 'Unrecognizable date format - second.'
	    GOTO, HANDLE_ERROR
	END ELSE SECOND = DOUBLE(REFORM(TM(2,*)))
;
;  If the hour is 100 or more then the colon must have been omitted.
;
	IF HOUR[0] GE 100 THEN BEGIN
	    IF HOUR[0] GT 10000 THEN BEGIN
		SECOND = HOUR MOD 100
		HOUR = FIX(HOUR / 100)
	    ENDIF
	    MINUTE = HOUR MOD 100
	    HOUR = FIX(HOUR / 100)
	END ELSE HOUR = FIX(HOUR)
;
;  If the original time string ended in PM, then add 12 to the hour.
;
	W = WHERE(AMPM_TEST EQ 'PM', COUNT)
	IF COUNT GT 0 THEN HOUR(W) = HOUR(W) + 12
;
;  If only one date was passed, then make the date variables scalar.
;
	IF N_ELEMENTS(YEAR) EQ 1 THEN BEGIN
	    YEAR   = YEAR[0]
	    MONTH  = MONTH[0]
	    DAY    = DAY[0]
	ENDIF
;
;  If only one time was passed, then make the time variables scalar.
;
	IF N_ELEMENTS(HOUR) EQ 1 THEN BEGIN
	    HOUR   = HOUR[0]
	    MINUTE = MINUTE[0]
	    SECOND = SECOND[0]
	ENDIF
;
;  Store everything in the structure variable.
;
        
	RSLT.YEAR   = YEAR
	RSLT.MONTH  = MONTH
	RSLT.DAY    = DAY
	RSLT.HOUR   = HOUR
	RSLT.MINUTE = MINUTE
	MILLISECOND = ROUND(1000*SECOND)
	RSLT.SECOND = MILLISECOND / 1000
	RSLT.MILLISECOND = MILLISECOND MOD 1000
	IF KEYWORD_SET(EXTERNAL) THEN CHECK_EXT_TIME, RSLT
;
;  If the input time was a TAI time, then convert to UTC.
;
	IF TAI_TIME THEN RSLT = TAI2UTC( UTC2TAI(RSLT, /NOCORRECT), /EXTERNAL)
;
;  If the EXTERNAL keyword is not set, then convert the date into the CDS
;  internal format.
;
FINISH:
	IF NOT KEYWORD_SET(EXTERNAL) THEN RSLT = UTC2INT(RSLT,ERRMSG=ERRMSG)
	IF N_ELEMENTS(ERRMSG) NE 0 THEN $
		IF ERRMSG[0] EQ '' THEN ERRMSG = MESSAGE
	IF SZ[0] GT 1 THEN RSLT = REFORM(RSLT, SZ(1:SZ[0]), /OVERWRITE)
	RETURN, RSLT
;
;  Error handling point.
;
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) EQ 0 THEN BEGIN
            IF DATATYPE(UTC) EQ 'STR' THEN MESSAGE=MESSAGE+' ['+UTC[0]+']'
	    MESSAGE, MESSAGE, /CONT
        ENDIF
	ERRMSG = MESSAGE
	RETURN, -1
;
	END
