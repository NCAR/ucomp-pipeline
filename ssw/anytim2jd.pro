;+
; Project     : SOHO - CDS     
;                   
; Name        : anytim2jd()
;               
; Purpose     : Converts any input time format to full Julian day.
;               
; Explanation : Converts any time format to the equivalent Julian
;               day value.  Returns result in a structure with the
;               tags int (long) and frac (double).
;               
; Use         : IDL>  jd = anytim2jd(any_format)
;    
; Inputs      : any_format - date/time in any of the acceptable CDS 
;                            time formats -- for acceptable formats see file 
;                            aaareadme.txt.
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns JD in a structure {int:0L,frac:0.0d0}.
;               
; Opt. Outputs: None
;               
; Keywords    : ERRMSG  =  If defined and passed, then any error messages will
;                          be returned to the user in this parameter rather 
;                          than being printed to the screen.  If no errors are
;                          encountered, then a null string is returned.  In 
;                          order to use this feature, the string ERRMSG must 
;                          be defined first, e.g.,
;
;                             ERRMSG = ''
;                             JD = anytim2jd ( DT, ERRMSG=ERRMSG, ...)
;                             IF ERRMSG NE '' THEN ...
;
; Calls       : ANYTIM2UTC, INT2UTC, JULDAY
;
; Common      : None
;               
; Restrictions: None
;               
; Side effects: None
;               
; Category    : Util, time
;               
; Prev. Hist. : None
;
; Written     : C D Pike, RAL, 16-May-94
;               
; Modified    :	Version 1, C D Pike, RAL, 16-May-94
;		Version 2, William Thompson, GSFC, 14 November 1994
;			Changed .DAY to .MJD
;		Version 3, Donald G. Luttermoser, GSFC/ARC, 20 December 1994
;			Added the keyword ERRMSG.  Included ON_ERROR flag.
;		Version 4, Donald G. Luttermoser, GSFC/ARC, 30 January 1995
;			Added ERRMSG keyword to internally called procedured.
;			Made error handling routine more robust.
;		Version 5, Donald G. Luttermoser, GSFC/ARC, 13 February 1995
;			Allowed for input to be either scalar or vector.
;		Version 6, William Thompson, GSFC, 28 January 1997
;			Allow for long input arrays.
;		Version 7, Zarro, GSFC, 4 Feb 1997
;			Changed name from ANYTIM2JD
;
; Version     :	Version 7
;-            

function anytim2jd, dt, errmsg=errmsg

;
;  form output format
;
jd = {int:0L,frac:0.0d0}
if n_elements(dt) gt 1 then jd = replicate(jd, n_elements(dt))
message=''

on_error, 2   ;  Return to the caller of this procedure if error occurs.

;
; See if any parameters were passed
;
if n_params() eq 0 then begin
	message = 'Syntax:  JD = ANYTIM2JD(DATE-TIME)'
	goto, handle_error
endif

;
;  convert input to internal format
;
utc = anytim2utc(dt,errmsg=errmsg)
if n_elements(errmsg) ne 0 then $
	if errmsg(0) ne '' then return, jd   ;  ERRMSG set in called procedure

if utc(0).mjd eq 0 then begin
 	message='Error in determination of Modified Julian Date.'
	goto, handle_error
endif

;
; to CDS external format
;
eutc = int2utc(utc,errmsg=errmsg)
if n_elements(errmsg) ne 0 then $
	if errmsg(0) ne '' then return, jd   ;  ERRMSG set in called procedure

;
;  get integer Julian day for day which starts at noon
;  (note that JULDAY is an IDL library function, no ERRMSG keyword can be set)
;
for i=0L,n_elements(dt)-1 do begin
	jd(i).int = julday(eutc(i).month,eutc(i).day,eutc(i).year)
;
;  was time requested before noon?
;
	if eutc(i).hour lt 12 then begin
		jd(i).int = jd(i).int - 1
		eutc(i).hour = eutc(i).hour + 12
	endif else begin
		eutc(i).hour = eutc(i).hour - 12
	endelse
;
;  form fraction of day
;
	jd(i).frac = eutc(i).hour/24.0d0 + eutc(i).minute/1440.0d0 + $
          (eutc(i).second + eutc(i).millisecond/1000.0d0)/86400.0d0
endfor
;
;  deliver
;
if n_elements(errmsg) ne 0 then errmsg = message
return, jd

;
; Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message
errmsg = message
return, jd
;
end
