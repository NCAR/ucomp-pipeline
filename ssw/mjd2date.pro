	PRO MJD2DATE, MJD, YEAR, MONTH, DAY, ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	MJD2DATE
;
; Purpose     :	Converts MJD to year, month, and day.
;
; Explanation :	This procedure takes a Modified Julian Day number, and returns
;		the corresponding calendar date in year, month, day.
;
; Use         :	MJD2DATE, MJD, YEAR, MONTH, DAY
;
; Inputs      :	MJD	= Modified Julian Day number.
;
; Opt. Inputs :	None.
;
; Outputs     :	YEAR	= Calendar year corresponding to MJD.
;		MONTH	= Calendar month, from 1-12.
;		DAY	= Calendar day, from 1-31, depending on the month.
;
; Opt. Outputs:	None.
;
; Keywords    :	ERRMSG	= If defined and passed, then any error messages 
;			  will be returned to the user in this parameter 
;			  rather than being handled by the IDL MESSAGE 
;			  utility.  If no errors are encountered, then a null 
;			  string is returned.  In order to use this feature, 
;			  the string ERRMSG must be defined first, e.g.,
;
;				ERRMSG = ''
;				MJD2DATE, MJD, YEAR, MONTH, DAY, ERRMSG=ERRMSG
;				IF ERRMSG NE '' THEN ...
;
; Calls       :	None.
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	Utilities, Time.
;
; Prev. Hist. :	None.  However, part of the logic of this routine is taken from
;		DAYCNV by B. Pfarr, GSFC.
;
; Written     :	William Thompson, GSFC, 13 September 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 13 September 1993.
;		Version 2, Donald G. Luttermoser, GSFC/ARC, 28 December 1994.
;			Added the keyword ERRMSG.  Note that there are no
;			internally called procedures that use the ERRMSG 
;			keyword.
;		Version 3, Donald G. Luttermoser, GSFC/ARC, 30 January 1995.
;			Made the error handling procedure more robust.  Note
;			that this routine handles both scalars and vectors as
;			input.
;
; Version     :	Version 3, 30 January 1995.
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Check the number of parameters.
;
	IF N_PARAMS() NE 4 THEN BEGIN
		MESSAGE = 'Syntax:  MJD2DATE, MJD, YEAR, MONTH, DAY'
		GOTO, HANDLE_ERROR
	ENDIF
;
;  From the Modified Julian Day, calculate the Julian Day number corresponding
;  to noon of that same day.
;
	JD = LONG(2400001.D0 + MJD)
;
;  From the Julian Day number, calculate the year, month and day, using the
;  algorithm by Fliegel and Van Flandern (1968) reprinted in the Explanatory
;  Supplement to the Astronomical Almanac, 1992.
;
	L = JD + 68569
	N = 4 * L / 146097
	L = L - (146097 * N + 3) / 4
	YEAR = 4000 * (L + 1) / 1461001
	L = L - 1461 * YEAR / 4 + 31
	MONTH = 80 * L / 2447
	DAY = L - 2447 * MONTH / 80
	L = MONTH / 11
	MONTH = MONTH + 2 - 12 * L
	YEAR = 100 * (N - 49) + YEAR + L
;
	IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
	RETURN
;
; Error handling point.
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) EQ 0 THEN MESSAGE, MESSAGE
	ERRMSG = MESSAGE
	RETURN
;
	END
