;+
; Project     : SOHO - CDS     
;                   
; Name        : ANYTIM2UTC()
;               
; Purpose     : Converts (almost) any time format to CDS UTC format.
;               
; Explanation : Tests the type of input and tries to use the appropriate
;               conversion routine to create the date/time in CDS UTC
;               format (either internal (default), external or string)
;               CDS time format.
;               
; Use         : IDL>  utc = anytim2utc(any_format)
;    
; Inputs      : any_format - date/time in any of the acceptable CDS 
;                            time formats -- for acceptable formats see file 
;                            aaareadme.txt.
;               
; Opt. Inputs : None
;               
; Outputs     : Function returns CDS UTC time structure.
;               
; Opt. Outputs: None
;               
; Keywords    : EXTERNAL  = Create output in external format
;               CCSDS     = Create string output in CCSDS format
;               ECS       = Create string output in ECS format
;		VMS	  = Create string output in VMS format
;		STIME	  = Create string output in STIME format
;
;		Only one of the above keywords can be set.  If none of them are
;		set, then the output is in internal format.  The following
;		keywords are only valid if a string format was selected.
;
;		DMY	  = Normally the date is in the order year-month-day.
;			    However, if DMY is set then the order is
;			    day-month-year.  Note that if the month is given as
;			    a character string, then the default is
;			    day-month-year.
;
;		MDY	  = If set, then the date is in the order
;			    month-day-year.
;
;		YMD	  = If set, then the date is in the order
;			    year-month-day.
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
;			    keywords.
;
;		The following keywords are always valid.
;
;		QUIET	  = If set, then no informational messages are printed.
;
;               ERRMSG    = If defined and passed, then any error messages 
;                           will be returned to the user in this parameter 
;                           rather than being printed to the screen.  If no
;                           errors are encountered, then a null string is
;                           returned.  In order to use this feature, the 
;                           string ERRMSG must be defined first, e.g.,
;
;                                ERRMSG = ''
;                                UTC = ANYTIM2UTC ( DT, ERRMSG=ERRMSG, ...)
;                                IF ERRMSG NE '' THEN ...
;
;               Other keywords to the underlying routines can also be passed,
;               via the _EXTRA mechanism.
;
; Calls       : DATATYPE, INT2UTC, STR2UTC
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
;			Added ERRMSG keyword to internally called procedures.
;			Made error handling routine more robust.
;		Version 5, Donald G. Luttermoser, GSFC/ARC, 8 February 1995
;			Allowed for input to be either scalar or vector.
;		Version 6, William Thompson, GSFC, 14 March 1995
;			Added keywords VDS, STIME, TRUNCATE, DATE_ONLY,
;			TIME_ONLY, UPPERCASE
;		Version 7, William Thompson, GSFC, 5 May 1995
;			Fixed bug with use of ERRMSG keyword.
;			Made so that TAI times are supported.
;		Version 8, William Thompson, GSFC, 8 May 1995
;			Fixed bug introduced in version 7
;               Version 9 C D Pike, RAL, 17-May-95
;                       Handle time only (no date) string input.
;		Version 10, William Thompson, GSFC, 20 December 1995
;			Fixed bug with use of ERRMSG keyword when string
;			contained no "-" characters.
;		Version 11, William Thompson, GSFC, 23 October 1996
;			Added keywords DMY, MDY, YMD.
;			Removed attempt at automatic recognition of DMY
;			option--no longer needed with version 11 of STR2UTC.
;		Version 12, William Thompson, GSFC, 28 January 1997
;			Allow for long input arrays.
;		Version 13, William Thompson, GSFC, 17 September 1997
;			Added keyword NOZ.
;		Version 14, 05-Oct-1999, William Thompson, GSFC
;			Add support for Yohkoh 7-element external time.
;               Version 15, 11-Aug-2003, William Thompson, GSFC
;                       Implement many keywords through _EXTRA.
;               Version 16, 31-Mar-2004, Zarro (L-3Com/GSFC)
;                       Fixed error message bug
;               Version 17, 25-Oct-2005, William Thompson, GSFC
;                       Handle structures through UTC2INT - interprets any
;                       structure with MJD and TIME as CDS internal time
;               Version 18, 07-Dec-2005, William Thompson, GSFC
;                       Add support for Yohkoh {DAY:, TIME:} structures.
;               Version 19, 20-Jun-2006, William Thompson, GSFC
;                       Preserve dimensionality
;               Version 20, 12-Mar-2007, WTT, correct bug in Yohkoh support
;               Version 21, 27-Sep-2007, WTT, let UTC2STR handle strings
;-            
;
function anytim2utc, dt, external=external, ccsds=ccsds, ecs=ecs, VMS=VMS, $
	STIME=STIME, errmsg=errmsg, QUIET=QUIET, _EXTRA=_EXTRA

;
;  set default return value
;
utc = {cds_int_time, mjd: 0L, time: 0L}

on_error, 2   ;  Return to the caller of this procedure if error occurs.
message=''    ;  Error message returned via ERRMSG if error is encountered.
;
;  see if any parameters were passed
;
dims = 0
if n_params() eq 0 then begin
	message = 'Syntax:  UTC = ANYTIM2UTC(DATE-TIME)'
	goto, handle_error
endif

;
;  determine type and dimensionality of input
;
type = datatype(dt,1)
sz = size(dt)
if sz[0] gt 0 then dims=sz[1:sz[0]]

;
; see if the input is an array
;
np = n_elements(dt)
if np gt 1 then utc = replicate(utc, np)

;
; act accordingly
;
case type of
      'String':  begin
                    test = str2utc(dt, errmsg=errmsg, _extra=_extra)
                    if n_elements(errmsg) ne 0 then message=errmsg
                    if message eq '' then utc = test
                 end

   'Structure':  begin
                       errmsg0 = ''
                       utc = utc2int(dt,errmsg=errmsg0,_extra=_extra)
                       if n_elements(errmsg) ne 0 then errmsg=errmsg0
;
;  If the structure was unrecognized, try looking for the Yohkoh tags DAY and
;  TIME.
;
                       if errmsg0 ne '' then begin
                           if tag_exist(dt,'day') and tag_exist(dt,'time') $
                             then begin
                               temp = {mjd: 0L, time: 0L}
                               temp = replicate(temp, n_elements(dt))
                               temp.mjd = dt.day + 43873L
                               temp.time = dt.time
                               errmsg0 = ''
                               utc = utc2int(temp,errmsg=errmsg0,_extra=_extra)
                               if n_elements(errmsg) ne 0 then errmsg=errmsg0
                           endif
                       endif
                       if n_elements(errmsg) ne 0 then message=errmsg else $
                         if errmsg0 ne '' then message, errmsg0
                 end
      'Double':  utc = tai2utc(dt,_extra=_extra)
;
;  If a seven element array, then assume the input is in Yohkoh external
;  format, where the array elements are
;
;	     [HOUR, MINUTE, SECOND, MILLISECOND, DAY, MONTH, YEAR]
;
          else:  begin
		    if dims[0] eq 7 then begin
			if not keyword_set(quiet) then message, /info,	$
				'Assuming Yohkoh 7-element external time'
			utc = {cds_ext_time,	$
				year:	0,	$
				month:	0,	$
				day:	0,	$
				hour:	0,	$
				minute:	0,	$
				second:	0,	$
				millisecond: 0}
			n_dates = n_elements(dt) / 7
                        if n_dates gt 1 then begin
                            dims = dims[1:*]
			    utc = replicate(utc, n_dates)
                        end else dims=0
			temp = reform(dt,7,n_dates)
			year = reform(temp(6,*))
			w = where(year lt 50, count)
			if count gt 0 then year(w) = year(w) + 2000
			w = where(year lt 100, count)
			if count gt 0 then year(w) = year(w) + 1900
			utc(*).year	   = year
			utc(*).month	   = reform(temp(5,*))
			utc(*).day	   = reform(temp(4,*))
			utc(*).hour	   = reform(temp(0,*))
			utc(*).minute	   = reform(temp(1,*))
			utc(*).second	   = reform(temp(2,*))
			utc(*).millisecond = reform(temp(3,*))
			if keyword_set(external) then goto, exit_point else $
				utc = utc2int(utc,_extra=_extra)
		    end else message='ANYTIM2UTC:  Unrecognized input format.'
		 end
endcase

if message ne '' then goto, handle_error

if n_elements(errmsg) ne 0 then errmsg = ''
 
if keyword_set(external) or keyword_set(ccsds) or keyword_set(ecs) or $
		keyword_set(vms) or keyword_set(stime) then begin
    utc = int2utc(utc,ccsds=ccsds,ecs=ecs,vms=vms,stime=stime,	$
	errmsg=errmsg,_extra=_extra)
    goto, exit_point
end else goto, exit_point

;
; Error handling point.
;
handle_error:
if n_elements(errmsg) eq 0 then message, message
errmsg = message
;
; Exit point.
;
exit_point:
if n_elements(dims) gt 1 then utc = reform(utc, dims, /overwrite)
return, utc
;
end
