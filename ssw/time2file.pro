function time2file, times, delimit=delimit, $
   seconds=seconds, year2digit=year2digit, date_only=date_only
;
;   Name: time2file
;
;   Purpose: convert input times (any SSW format) -> [YY]YYMMDD?HHMM[SS]
;
;   Input Parameters:
;      times - time array , any "standard" format (anytim.pro compatible)
;
;   Output:
;      function returns string array of 'filenames' (time portion)
;
;   Keyword Parameters:
;      delimit -    string delimter between date and time (default='_')
;      seconds -    if set, include SECONDS    - HHMMSS (default=HHMM)
;      year2digit - if set, make year 2 digits - YYMMDD (default=YYYYMMDD)
;      date_only  - if set, only return date portion YYYYMMDD or YYMMDD
;
;   Calling Sequence:
;      filenames=time2file(timearray )
;
;   Calling Examples:
;    IDL> print,'myprefix'+ time2file(ut_time()) + '.gif'
;         myprefix19970506_1949.gif
;
;    IDL> more,time2file(index,/sec,delim='.')        ; from structure
;         19970430.002022
;         19970504.021803
;         19970506.085110
;  
;    IDL> more,time2file(timegrid('1-feb 12:35','1-feb 13:05',min=15))
;         19970201_1235
;	  19970201_1250
;         19970201_1305
;
;    IDL> more,time2file(timegrid('1-feb 12:35','1-feb 12:36',sec=20),/sec)
;         19970201_123500
;         19970201_123520
;         19970201_123540
;         19970201_123600
;  
;   History:
;      6-may-1997 - S.L.Freeland - extract code from dat2files et al.
;	18-Feb-1998 - M.D.Morrison - Return a scalar if single element (/date_only
;				     was returning a 1 element array
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;-
; force  keyword definition
seconds=keyword_set(seconds)
year2digit=keyword_set(year2digit)

; derive extraction parameters 
first=([0,2])(year2digit)
length=strlen('yyyymmdd_hhmm') + ([0,2])(seconds) - first

; Tactic - replace unwanted characters with blanks and then use
; strcompress(xxx,/remove) to efficiently destroy them
strtimes=str_replace(anytim(times,out_style='ecs'),' ','_') ; blank ->"_"
strtimes=str_replace(str_replace(strtimes,'/',' '),':',' ') ; delim ->" "
filenames=strmid(strcompress(strtimes,/remove),first,length)

if data_chk(delimit,/string) then $
   filenames=str_replace(filenames,'_',delimit) else delimit='_'

if keyword_set(date_only) then filenames=ssw_strsplit(filenames,delimit,/head)

if (n_elements(filenames) eq 1) then filenames = filenames(0)	;make is scalar
return, filenames
end
