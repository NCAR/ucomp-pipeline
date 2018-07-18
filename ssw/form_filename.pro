	FUNCTION FORM_FILENAME, FILENAME, EXTENSION, DIRECTORY=DIRECTORY
;+
; Project     : SOHO - CDS
;
; Name        : 
;	FORM_FILENAME()
; Purpose     : 
;	Adds default paths and extensions to filenames.
; Explanation : 
;	This procedure tests whether or not a given filename already has an
;	extension on it.  If not, then a default extension is appended.
;	Optionally, the same can be done with a default path.  This is similar
;	to using the DEFAULT keyword with the OPEN statement in VMS.
;
;	Using this routine together with environment variables for the optional
;	directory path allows an OS-independent approach to forming filenames.
; Use         : 
;	result = FORM_FILENAME( FILENAME, EXTENSION )
;
;	OPENW, UNIT, FORM_FILENAME( FILENAME, '.fits' ), ...
;
; Inputs      : 
;	FILENAME  = Name of file to test.
;	EXTENSION = Default filename extension.  Ignored if FILENAME already
;		    contains an extension.
; Opt. Inputs : 
;	None.
; Outputs     : 
;	Result of function is the name of the file complete with (optional)
;	directory and extension.
; Opt. Outputs: 
;	None.
; Keywords    : 
;	DIRECTORY = Default directory path.  Ignored if FILENAME already
;		    contains directory information.
; Calls       : 
;	STR_SEP, OS_FAMILY
; Common      : 
;	None.
; Restrictions: 
;	None.
; Side effects: 
;	None.
; Category    : 
;	Utilites, Operating System.
; Prev. Hist. : 
;	William Thompson, October 1991.
; Written     : 
;	William Thompson, GSFC, October 1991.
; Modified    : 
;	Version 1, William Thompson, GSFC, 7 May 1993.
;		Incorporated into CDS library.
;		Changed to be compatible with CONCAT_DIR by M. Morrison.
;		Made more OS-independent.  Relaxed punctuation requirements.
;		Fixed small bug with blank extensions.
;		Added IDL for Windows compatibility.
;	Version 2, William Thompson, GSFC, 29 August 1995
;		Modified to use OS_FAMILY
; Version     : 
;	Version 2, 29 August 1995
;-
;
	ON_ERROR, 2
;
;  Check the number of parameters:
;
	IF N_PARAMS() NE 2 THEN MESSAGE,	$
		'Syntax:  Result = FORM_FILENAME( FILENAME, EXTENSION )'
;
;  If DIRECTORY was not passed, then equivalent to the null string.
;
	IF N_ELEMENTS(DIRECTORY) EQ 1 THEN DIR = DIRECTORY ELSE DIR = ''
;
;  Remove any trailing "/" or ":" characters.
;
	REPEAT BEGIN
		CHAR = STRMID(DIR,STRLEN(DIR)-1,1)
		IF (CHAR EQ '/') OR (CHAR EQ ':') THEN	$
			DIR = STRMID(DIR,0,STRLEN(DIR)-1)
;
;  See if it is really an environment variable.  If so, then decompose the
;  environmental variable into its constituent path(s).  In VMS, GETENV
;  requires an uppercase argument.
;
		TEMP = DIR
		IF !VERSION.OS EQ 'vms' THEN TEMP = STRUPCASE(TEMP)
		TEST = GETENV(TEMP)
;
;  If that doesn't yield anything, and the path begins with the $ prompt, then
;  try what follows after the $.
;
		IF TEST EQ '' THEN IF STRMID(TEMP,0,1) EQ '$' THEN BEGIN
			FOLLOWING = STRMID(TEMP,1,STRLEN(TEMP)-1)
			TEST = GETENV(FOLLOWING)
		ENDIF
;
;  If something was found, then take the first path in the list.  Paths may be
;  separated by commas, or optionally by semicolons in Microsoft Windows or
;  colons in Unix.
;
		IF TEST NE '' THEN BEGIN
			CASE OS_FAMILY() OF
				'vms': SEP = ','
				'Windows': SEP = ';'
				ELSE: SEP = ':'
			ENDCASE
			DIR = (STR_SEP(TEST,SEP))(0)
			DIR = (STR_SEP(DIR,','))(0)
		ENDIF
;
;  Keep translating until done.
;
	ENDREP UNTIL TEST EQ ''
;
;  Check whether or not the directory path ends in the correct character.  In
;  VMS, if the path does not end in "]" or ":", then append the ":" character.
;  In Unix or Microsoft Windows, if the path does not end in "/" or "\"
;  respectively, then append it.
;
	IF DIR NE '' THEN BEGIN
	    LAST = STRMID(DIR, STRLEN(DIR)-1, 1)
	    CASE OS_FAMILY() OF
		'vms':  IF (LAST NE ']') AND (LAST NE ':') THEN DIR = DIR + ':'
		'Windows':  IF LAST NE '\' THEN DIR = DIR + '\'
		ELSE:  IF LAST NE '/' THEN DIR = DIR + '/'
	    ENDCASE
	ENDIF
;
;  If VMS, then look for the last ']' or ':' character in the filename.  (There
;  might be multiple ':' characters in a filename if a hostname is given.)
;
	IF !VERSION.OS EQ 'vms' THEN BEGIN
		POS = STRPOS(FILENAME,']')
		IF POS EQ -1 THEN BEGIN
			TEMP = FILENAME
			LEN = STRLEN(FILENAME)
			POS = -1
			COLON = STRPOS(TEMP,':')
			WHILE COLON NE -1 DO BEGIN
				POS = POS + COLON + 1
				LEN = LEN - COLON - 1
				TEMP = STRMID(TEMP,COLON+1,LEN)
				COLON = STRPOS(TEMP,':')
			ENDWHILE
		ENDIF
;
;  In Microsoft Windows find the last '\' or ':' character.
;
	END ELSE IF OS_FAMILY() EQ 'Windows' THEN BEGIN
		TEMP = FILENAME
		LEN = STRLEN(FILENAME)
		POS = -1
		SLASH = STRPOS(TEMP,'\')
		WHILE SLASH NE -1 DO BEGIN
			POS = POS + SLASH + 1
			LEN = LEN - SLASH - 1
			TEMP = STRMID(TEMP,SLASH+1,LEN)
			SLASH = STRPOS(TEMP,'\')
		ENDWHILE
		IF POS EQ -1 THEN POS = STRPOS(TEMP,':')
;
;  Otherwise, in UNIX find the last '/' character.
;
	END ELSE BEGIN
		TEMP = FILENAME
		LEN = STRLEN(FILENAME)
		POS = -1
		SLASH = STRPOS(TEMP,'/')
		WHILE SLASH NE -1 DO BEGIN
			POS = POS + SLASH + 1
			LEN = LEN - SLASH - 1
			TEMP = STRMID(TEMP,SLASH+1,LEN)
			SLASH = STRPOS(TEMP,'/')
		ENDWHILE
	ENDELSE
;
;  If not found, then prepend the directory to the filename.
;
	IF POS EQ -1 THEN BEGIN
		POS = STRLEN(DIR)
		FILE = DIR + FILENAME
	END ELSE BEGIN
		FILE = FILENAME
	ENDELSE
;
;  If the extension does not begin with a period, then add it.
;
	CHAR = STRMID(EXTENSION,0,1)
	IF (CHAR NE '.') AND (EXTENSION NE '') THEN BEGIN
		EXT = '.' + EXTENSION
	END ELSE BEGIN
		EXT = EXTENSION
	ENDELSE
;
;  Look for a period after any directory information.  If not found, then add
;  the default extension.
;
	TEMP = STRMID(FILE,POS+1,STRLEN(FILE)-POS-1)
	IF STRPOS(TEMP,'.') EQ -1 THEN FILE = FILE + EXT
;
	RETURN,FILE
	END
