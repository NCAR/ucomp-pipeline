	FUNCTION UTC2INT, UTC, ERRMSG=ERRMSG
;+
; Project     :	SOHO - CDS
;
; Name        :	UTC2INT()
;
; Purpose     :	Converts CCSDS calendar time to internal format.
;
; Explanation :	This procedure converts Coordinated Universal Time (UTC)
;		calendar time, as either a seven element structure variable, or
;		in the CCSDS/ISO 8601 ASCII calendar format, into CDS internal
;		format.  For notes on various time formats, see file 
;		aaareadme.txt.
;
; Use         :	Result = UTC2INT( UTC )
;
; Inputs      :	UTC	= This can either be a structure with the tags YEAR,
;			  MONTH, DAY, HOUR, MINUTE, SECOND, MILLISECOND, or a
;			  character string in CCSDS/ISO 8601 format, e.g.
;
;				"1988-01-18T17:20:43.123Z"
;
;			  or one of it's variants--see STR2UTC for more
;			  details.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is a structure with the tags:
;
;			MJD	= The Modified Julian Day number
;			TIME	= The time of day, in milliseconds since the
;				  start of the day.
;
; Opt. Outputs:	None.
;
; Keywords    :	ERRMSG       =	If defined and passed, then any error messages 
;				will be returned to the user in this parameter 
;				rather than being handled by the IDL MESSAGE 
;				utility.  If no errors are encountered, then a 
;				null string is returned.  In order to use this 
;				feature, the string ERRMSG must be defined 
;				first, e.g.,
;
;					ERRMSG = ''
;					RESULT = UTC2INT( UTC, ERRMSG=ERRMSG )
;					IF ERRMSG NE '' THEN ...
;
; Calls       :	DATATYPE, DATE2MJD, STR2UTC
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	If an error is encountered and the ERRMSG keyword is set, 
;		UTC2INT returns an integer scalar equal to -1.
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
;			Added the keyword ERRMSG.  Check to see if the input
;			structure (if sent) has 2 or 7 tags.  If 2 tags (MJD &
;			TIME), this procedure returns the input variable with 
;			no changes (i.e., already in CDS internal format).
;		Version 4, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG keyword to internally called procedures.
;			Made error handling routine more robust.  Note that 
;			this procedure allows both scalars and vectors as
;			input.
;
; Version     :	Version 4, 30 January 1995
;-
;
	ON_ERROR, 2  ; Return to the caller of this procedure if error occurs.
	MESSAGE=''   ; Error message that is returned if ERRMSG keyword set.
;
;  Check the input parameter.
;
	IF N_PARAMS() NE 1 THEN MESSAGE = 'Syntax:  Result = UTC2INT( UTC )' $
	 ELSE BEGIN
		IF N_ELEMENTS(ERRMSG) NE 0 THEN ERRMSG = MESSAGE
		CASE DATATYPE(UTC,1) OF
		  'String':	BEGIN
			UT = STR2UTC(UTC,/EXTERNAL,ERRMSG=ERRMSG)
			IF N_ELEMENTS(ERRMSG) NE 0 THEN $
				IF ERRMSG(0) NE '' THEN RETURN, -1
			END
		  'Structure':	BEGIN
			CASE N_TAGS(UTC) OF
				2:  RETURN, UTC  ; Input already in CDS format.
				7:  UT = UTC 
				ELSE:  MESSAGE = $
				 	'UTC structure must have 7 tags.'
			ENDCASE
			END
		  ELSE:  MESSAGE = $
			  'UTC must be either a structure or a string.'
		ENDCASE
	ENDELSE
	IF MESSAGE NE '' THEN GOTO, HANDLE_ERROR
;
;  Convert the date into a Modified Julian Day number, and the number of
;  milliseconds into the day.
;
	DATE = {CDS_INT_TIME, MJD: 0L, TIME: 0L}
	IF N_ELEMENTS(UT) GT 1 THEN BEGIN
		DATE = REPLICATE(DATE,N_ELEMENTS(UT))
		SZ = SIZE(UTC)
		DATE = REFORM(DATE,SZ(1:SZ(0)))
	ENDIF
	DATE.MJD = DATE2MJD(UT.YEAR,UT.MONTH,UT.DAY)
	DATE.TIME = UT.HOUR*3600000L + UT.MINUTE*60000L + UT.SECOND*1000L + $
		UT.MILLISECOND
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
