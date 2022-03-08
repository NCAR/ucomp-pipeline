	FUNCTION DATE2MJD, YEAR, MONTH, DAY, ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	DATE2MJD()
;
; Purpose     :	Convert calendar dates to Modified Julian Days.
;
; Explanation :	This procedure calculates the Modified Julian Day number from
;		the year, month and day, or from the year, day-of-year.
;
; Use         :	Result = DATE2MJD(YEAR, MONTH, DAY)
;		Result = DATE2MJD(YEAR, DOY)
;
; Inputs      :	YEAR	= Calendar year, e.g. 1989.  All four digits are
;			  required.
;
; Opt. Inputs :	MONTH	= Calendar month, from 1-12.
;		DAY	= Calendar day, from 1-31, depending on the month.
;
;				or
;
;		DOY	= Day-of-year, from 1-365 or 1-366, depending on the
;			  year.
;
;		Either MONTH and DAY, or DOY must be passed.
;
; Outputs     :	The result of the function is the Modified Julian Day number
;		for the date in question.  It is an integral number--fractional
;		days are not considered.
;
; Opt. Outputs:	None.
;
; Keywords    :	ERRMSG  =  If defined and passed, then any error messages 
;                          will be returned to the user in this parameter 
;                          rather than being handled by the IDL MESSAGE 
;                          utility.  If no errors are encountered, then a null
;                          string is returned.  In order to use this feature,
;                          the string ERRMSG must be defined first, e.g.,
;
;                            ERRMSG = ''
;                            MJD = DATE2MJD ( YEAR, MONTH, DAY, ERRMSG=ERRMSG )
;                            IF ERRMSG NE '' THEN ...
;
; Calls       :	DATATYPE
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	If number of parameters sent is invalid, ERRMSG is returned as
;               a string array of 2 elements if the keyword ERRMSG is set.
;		Also, the result returned has a value of -1.
;
; Category    :	Utilities, Time.
;
; Prev. Hist. :	None.  However, part of the logic of this routine is based on
;		JDCNV by B. Pfarr, GSFC.
;
; Written     :	William Thompson, GSFC, 13 September 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 13 September 1993.
;		Version 2, Donald G. Luttermoser, GSFC/ARC, 20 December 1994.
;			Added the keyword ERRMSG.  Added test for month to 
;			make sure a string is not passed.  Note that there are
;			no internal procedures called that use the ERRMSG
;			keyword.
;		Version 3, Donald G. Luttermoser, GSFC/ARC, 30 January 1995.
;			Made the error handling routine more robust.  Note 
;			this routine can handle both vector and scalar input.
;
; Version     :	Version 3, 30 January 1995.
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Report error if a string is passed in the month variable.
;
	IF DATATYPE(MONTH,1) EQ 'String' THEN BEGIN
		MESSAGE = 'MONTH must be an integer variable (1-12).'
		GOTO, HANDLE_ERROR
	ENDIF
;
;  Depending on the number of parameters, either the year, month, day or the
;  year, day-of-year was passed.  Calculate the Modified Julian Day number
;  accordingly, using a modification of the algorithm by Fliegel and Van
;  Flandern (1968) reprinted in the Explanatory Supplement to the Astronomical
;  Almanac, 1992.
;                              
	CASE N_PARAMS() OF
		2:  BEGIN		;Year, day-of-year
			Y = LONG(YEAR)
			D = LONG(MONTH)
			IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
			RETURN,  D - 2431740L + 1461*(Y + 4799)/4 -	$
				3*((Y + 4899)/100)/4
			END
		3:  BEGIN		;Year, month, day
			Y = LONG(YEAR)
			M = LONG(MONTH)
			D = LONG(DAY)
			L = (M-14)/12
			IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
			RETURN,  D - 2432076L + 1461*(Y+4800+L)/4 +	$
				367*(M-2-L*12)/12 - 3*((Y+4900+L)/100)/4
			END
		ELSE:  BEGIN
			MESSAGE=STRARR(2)
                        MESSAGE(0) = $
			 'Syntax:  Result = DATE2MJD(YEAR,MONTH,DAY)'
			MESSAGE(1) = 'Or:      Result = DATE2MJD(YEAR,DOY)'
			GOTO, HANDLE_ERROR
			END
	ENDCASE
;
; Error handling point.
;
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) EQ 0 THEN BEGIN
		IF N_ELEMENTS(MESSAGE) EQ 2 THEN BEGIN
			MESSAGE, /CONTINUE, MESSAGE(0)
			MESSAGE, MESSAGE(1)
		ENDIF ELSE MESSAGE, MESSAGE
	ENDIF
	ERRMSG = MESSAGE
	RETURN, -1L
;
	END
