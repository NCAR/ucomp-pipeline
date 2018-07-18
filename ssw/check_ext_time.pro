	PRO CHECK_EXT_TIME, EXT, ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	CHECK_EXT_TIME
;
; Purpose     :	Checks CDS external time values for logical consistency.
;
; Explanation :	This procedure checks time values in CDS external format to
;		ensure that the date-time values have valid values.  If a 
;		value is found inaccurate, then these values are repaired
;		with CHECK_INT_TIME.
;
;		This procedure should be called whenever the external time is
;		modified.
;
; Use         :	CHECK_EXT_TIME, EXT
;
; Inputs      :	EXT	= The UTC date/time as a data structure with the
;			  elements:
;
;				YEAR		= Integer year (1995).
;				MONTH		= Integer month (1-12).
;				DAY		= Integer day (1-31).
;				HOUR		= Integer hour (0-23).
;				MINUTE		= Integer minute (0-59).
;				SECOND		= Integer second (0-59).
;				MILLISECOND	= Integer millisec (0-999).
;
; Opt. Inputs :	None.
;
; Outputs     :	The input array will be repaired to reflect the correct values.
;
; Opt. Outputs:	None.
;
; Keywords    :	ERRMSG	= If defined and passed, then any error messages 
;			  will be returned to the user in this parameter 
;			  rather than using IDL's MESSAGE utility.  If no
;			  errors are encountered, then a null string is
;			  returned.  In order to use this feature, the 
;			  string ERRMSG must be defined first, e.g.,
;
;				ERRMSG = ''
;				CHECK_EXT_TIME, EXT, ERRMSG=ERRMSG
;				IF ERRMSG NE '' THEN ...
;
; Calls       :	DATATYPE, UTC2INT, INT2UTC, CHECK_INT_TIME
;
; Common      :	None.
;
; Restrictions:	Not valid for dates before 1 January 1972.
;
; Side effects:	None.
;
; Category    :	Utilities, Time.
;
; Prev. Hist. :	None, but uses CHECK_INT_TIME by W. Thompson, NASA/GSFC/ARC
;		to check and make the fix.
;
; Written     :	Donald G. Luttermoser, NASA/GSFC/ARC, 15 February 1995.
;
; Modified    :	Version 1, Donald G. Luttermoser, GSFC/ARC, 15 February 1995.
;
; Version     :	Version 1, 15 February 1995.
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE = '' ; Error message that is returned if ERRMSG keyword set.
	TAGCK = ['YEAR','MONTH','DAY','HOUR','MINUTE','SECOND','MILLISECOND']
;
;  Check the input array.
;
	IF N_PARAMS() NE 1 THEN BEGIN
		MESSAGE = 'Syntax:  CHECK_EXT_TIME, EXT'
	ENDIF ELSE BEGIN
		IF DATATYPE(EXT,1) NE 'Structure' THEN BEGIN
			MESSAGE = 'EXT must be a structure variable.'
		ENDIF ELSE BEGIN
			IF N_TAGS(EXT) NE 7 THEN BEGIN
				MESSAGE = $
	'EXT must have 7 tags: YEAR,MONTH,DAY,HOUR,MINUTE,SECOND,MILLISECOND.'
			ENDIF ELSE BEGIN
				TNAMES = STRUPCASE(TAG_NAMES(EXT))
				FOR I=0,6 DO BEGIN
				  QCK = WHERE(TNAMES EQ TAGCK(I))
				  IF QCK(0) EQ -1 THEN $
				   MESSAGE = 'Structure tag "'+TAGCK(I)+$
				   '" not found in EXT.'
				  IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
				ENDFOR
			ENDELSE
		ENDELSE
	ENDELSE
	IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
;
;  Use UTC2INT to convert EXT format to INT format.
;
	INT = UTC2INT( EXT, ERRMSG=ERRMSG )
	IF N_ELEMENTS(ERRMSG) NE 0 THEN $
		IF ERRMSG(0) NE '' THEN RETURN
;
;  Use CHECK_INT_TIME to check the day-time.
;
	CHECK_INT_TIME, INT, ERRMSG=ERRMSG
	IF N_ELEMENTS(ERRMSG) NE 0 THEN $
		IF ERRMSG(0) NE '' THEN RETURN
;
;  Convert corrected INT back to EXT.
;
	EXT = INT2UTC( INT, ERRMSG=ERRMSG )
	IF N_ELEMENTS(ERRMSG) NE 0 THEN $
		IF ERRMSG(0) NE '' THEN RETURN
;
;  Now return the corrected EXT date-time.
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
