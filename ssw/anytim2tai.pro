;+
; Project     : SOHO - CDS     
;                   
; Name        : ANYTIM2TAI()
;               
; Purpose     : Converts any standard CDS time format to TAI.
;               
; Explanation : Tests the type of input and tries to use the appropriate
;               conversion routine to create the date/time in CDS TAI
;               time format.
;               
; Use         : IDL>  tai = anytim2tai(any_format)
;    
; Inputs      : any_format - date/time in any of the acceptable CDS 
;                            time formats -- for acceptable formats see file 
;                            aaareadme.txt.
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns CDS TAI double precision time value.
;               
; Opt. Outputs: None
;               
; Keywords    : ERRMSG    = If defined and passed, then any error messages 
;                           will be returned to the user in this parameter 
;                           rather than being printed to the screen.  If no
;                           errors are encountered, then a null string is
;                           returned.  In order to use this feature, the 
;                           string ERRMSG must be defined first, e.g.,
;
;                                ERRMSG = ''
;                                TAI = ANYTIM2TAI ( DT, ERRMSG=ERRMSG, ...)
;                                IF ERRMSG NE '' THEN ...
;
; Calls       : DATATYPE, ANYTIM2UTC, UTC2TAI
;
; Common      : None
;               
; Restrictions: Conversions between TAI and UTC are not valid for dates prior
;               to 1 January 1972.
;               
; Side effects: None
;               
; Category    : Util, time
;               
; Prev. Hist. : Based on ANYTIM2UTC by C. D. Pike.
;
; Written     : William Thompson, GSFC, 20 May 1996
;               
; Modified    :	Version 1, William Thompson, GSFC, 20 May 1996
;		Version 2, 05-Oct-1999, William Thompson, GSFC
;			Add support for Yohkoh 7-element external time.
;		Version 3, 31-Jul-2001, William Thompson, GSFC
;			Changed MESSAGE to MESSAGE, /CONTINUE
;               Version 4, 16-Feb-2004, CDP.  Added /quiet keyword because it was
;                                             already required in the code.
;               Version 5, 08-Sep-2004, William Thompson, GSFC
;                       Added keyword NOCORRECT
;               Version 6, 07-Dec-2005, William Thompson, GSFC
;                       Moved handling of Yohkoh formats to ANYTIM2UTC
;
; Version     :	Version 6, 07-Dec-2005
;-            

function anytim2tai, dt, errmsg=errmsg, nocorrect=nocorrect, quiet=quiet
 
;
;  set default return value
;
tai = 0.0D0

on_error, 2   ;  Return to the caller of this procedure if error occurs.
message=''    ;  Error message returned via ERRMSG if error is encountered.
;
;  see if any parameters were passed
;
if n_params() eq 0 then begin
	message = 'Syntax:  TAI = ANYTIM2TAI(DATE-TIME)'
	goto, handle_error
endif

;
;  determine type of input 
;
type = datatype(dt,1)

;
; see if the input is an array
;
np = n_elements(dt)
if np gt 1 then tai = replicate(tai, np)

;
; act accordingly
;
case type of
      'Double':  tai = dt
          else:  begin
		message=''
                utc = anytim2utc(dt,errmsg=message)
                if message eq '' then tai = utc2tai(utc,nocorrect=nocorrect)
		end
endcase

if message eq '' then goto, finish
;
; Error handling point.
;
handle_error:
	if n_elements(errmsg) eq 0 then message, message, /continue
	errmsg = message
;
finish:
	return, tai
	end
