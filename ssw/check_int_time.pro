	PRO CHECK_INT_TIME, INT, ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	CHECK_INT_TIME
;
; Purpose     :	Checks CDS internal time values for logical consistency.
;
; Explanation :	This procedure checks time values in CDS internal format to
;		ensure that the milliseconds of day is neither negative nor
;		larger than the number of milliseconds in the day in question.
;		If either is true, then the day and time is repaired.  Leap
;		seconds are taken into account.
;
;		This procedure should be called whenever the internal time is
;		modified.
;
; Use         :	CHECK_INT_TIME, INT
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
; Outputs     :	The input array will be repaired to reflect the correct number
;		of milliseconds in the day.
;
; Opt. Outputs:	None.
;
; Keywords    :	ERRMSG    =  If defined and passed, then any error messages 
;                            will be returned to the user in this parameter 
;                            rather than using IDL's MESSAGE utility.  If no
;                            errors are encountered, then a null string is
;                            returned.  In order to use this feature, the 
;                            string ERRMSG must be defined first, e.g.,
;
;                                ERRMSG = ''
;                                CHECK_INT_TIME, INT, ERRMSG=ERRMSG
;                                IF ERRMSG NE '' THEN ...
;
; Calls       :	DATATYPE, GET_LEAP_SEC
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
; Side effects:	None.
;
; Category    :	Utilities, Time.
;
; Prev. Hist. :	Based on CHECK_TIME by M. Morrison, LPARL.
;
; Written     :	William Thompson, GSFC, 29 September 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 29 September 1993.
;		Version 2, Donald G. Luttermoser, GSFC/ARC, 20 December 1994
;			Added the keyword ERRMSG.  Added a check for the 
;			STRUCTURE-TAG names.
;		Version 3, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG keyword to internally called procedures.
;			Made the error handling routine more robust.  Note
;			that this procedure can handle both vectors and 
;			scalars.
;		Version 4, William Thompson, GSFC, 28 January 1997
;			Allow for long input arrays.
;               Version 5, William Thompson, GSFC, 25-Oct-2005
;                       Interpret any structure with tags MJD and TIME as CDS
;                       internal time.
;               Version 6, WTT, GSFC, 18-Apr-2017, change () to [] for arrays
;
; Version     :	Version 6, 18-Apr-2017
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Check the input array.
;
	IF N_PARAMS() NE 1 THEN BEGIN
		MESSAGE = 'Syntax:  CHECK_INT_TIME, INT'
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
;  Decompose the structure into the day and time parts.
;
	MJD = INT.MJD
	TIME = INT.TIME
;
;  Get the leap seconds information, and calculate the number of milliseconds
;  for each day in the input array.
;
	GET_LEAP_SEC, LEAP_MJD, ERRMSG=ERRMSG
	IF N_ELEMENTS(ERRMSG) NE 0 THEN $
		IF ERRMSG[0] NE '' THEN RETURN
	DAYLENGTH = 0*TIME + 86400000L
	FOR I = 0L,N_ELEMENTS(LEAP_MJD)-1 DO BEGIN
		W = WHERE(MJD EQ LEAP_MJD[I], N_LEAP)
		IF N_LEAP GT 0 THEN DAYLENGTH[W] = DAYLENGTH[W] + 1000
	ENDFOR
;
;  Find out whether or not any of the times in the input array are outside the
;  acceptable range (0 to DAYLENGTH-1).
;
	TMIN = MIN(TIME)
	EXCESS = MAX(TIME - DAYLENGTH) + 1
;
;  Keep repairing the times until done.
;
	WHILE (TMIN LT 0) OR (EXCESS GT 0) DO BEGIN
;
;  First of all, repair those times which are less than zero.  Before
;  correcting the time, first change the length of the day to reflect the
;  previous day.  Update TMIN.
;
		W = WHERE(TIME LT 0, COUNT)
		IF COUNT GT 0 THEN BEGIN
			MJD[W] = MJD[W] - 1
;
			WW = WHERE(DAYLENGTH[W] GT 86400000L, N_LEAP)
			IF N_LEAP GT 0 THEN DAYLENGTH[W[WW]] = 86400000L
;
			FOR I = 0L,N_ELEMENTS(LEAP_MJD)-1 DO BEGIN
				WW = WHERE(MJD[W] EQ LEAP_MJD[I], N_LEAP)
				IF N_LEAP GT 0 THEN DAYLENGTH[W[WW]] =	$
					DAYLENGTH[W[WW]] + 1000
			ENDFOR
;
			TIME[W] = TIME[W] + DAYLENGTH[W]
;
			TMIN = MIN(TIME[W])
		ENDIF
;
;  Next, repair those times which are longer than the length of the day.  After
;  repairing the time, update the length of the day to reflect the next day.
;  Update EXCESS.
;
		W = WHERE(TIME GE DAYLENGTH, COUNT)
		IF COUNT GT 0 THEN BEGIN
			MJD[W] = MJD[W] + 1
			TIME[W] = TIME[W] - DAYLENGTH[W]
;
			WW = WHERE(DAYLENGTH[W] GT 86400000L, N_LEAP)
			IF N_LEAP GT 0 THEN DAYLENGTH[W[WW]] = 86400000L
;
			FOR I = 0L,N_ELEMENTS(LEAP_MJD)-1 DO BEGIN
				WW = WHERE(MJD[W] EQ LEAP_MJD[I], N_LEAP)
				IF N_LEAP GT 0 THEN DAYLENGTH[W[WW]] =	$
					DAYLENGTH[W[WW]] + 1000
			ENDFOR
;
			EXCESS = MAX(TIME[W] - DAYLENGTH[W]) + 1
		ENDIF
	ENDWHILE
;
;  Reform the structure from the pieces.
;
	INT.MJD = MJD
	INT.TIME = TIME
;
	IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
	RETURN
;
; Error handling point.
;
HANDLE_ERROR:
	IF N_ELEMENTS(ERRMSG) EQ 0 THEN MESSAGE, MESSAGE
	ERRMSG = MESSAGE
	RETURN
;
	END
