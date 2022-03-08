;+
; Project     : RHESSI
;
; Name        : PARSE_TIME
;
; Purpose     : Parse time in a filename encoded with date/time, e.g.
;               sxi_20020101_010302.fits. Uses fast REGEX.
;
; Category    : I/O utility time 
;
; Syntax      : IDL> times=parse_time(files)
;
; Inputs      : FILES = file names 
;
; Outputs     : TIMES = structure with .year, .month, .day, .hour, .minute, 
;                       .millisecond fields.
;
; Keywords    : DELIM = time delimiter (def= '_')
;               COUNT = # of files that parse correctly
;               SS = indicies of files that parse correctly
;               YMD = year/month/day (output)
;               SEPARATOR = separator for YMD [def='/']
;               TAI = return time in TAI format
;               REGEX = user-supplied REGEX
;               UTC = return UTC format
;               SHORT = shorten YMD to using 2 digit year
;               MSECS = include optional _milliseconds
;
; History     : 10-Jan-2002, Zarro (EER/GSFC)
;               15-Dec-2004, Zarro (L-3Com/GSFC) - fixed IDL 6.1 space bug 
;               20-Feb-2005, Zarro (L-3Com/GSFC) - added /UTC
;               24-Oct-2010, Zarro (ADNET) 
;                - added optional underscore millisec delimiter
;               12-Nov-2014, Zarro (ADNET)
;                - support filenames without prefixes
;                  (e.g. 20070326_234800_s4euB.fts)
;               10-Aug-2018, Zarro (ADNET) -added /msecs
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function parse_time,file,delim=delim,err=err,count=count,ss=ss,ymd=ymd,$
                    separator=separator,tai=tai,vms=vms,truncate=truncate,$
                    extension=extension,regex=regex,names=names,_extra=extra,$
                    utc=utc,short=short,msecs=msecs

if n_elements(file) gt 1 then $
 dprint,'% '+get_caller()+' calling PARSE_TIME: ',trim(n_elements(file))

err=''
count=0
sz=size(file)

if is_string(separator,/blank) then sep=trim(separator) else sep='/'

if sz[n_elements(sz)-2] ne 7 then begin
 err='invalid file input'
 mprint,err,/cont
 return,''
endif

if is_string(regex) then sregex=regex else begin
 dyear='([0-9]{0,2}[0-9]{2})'
 mons='([0-9]{2})'
 days=mons
 hrs='([0-9]{0,2})'
 mins=hrs
 secs=hrs
 rest='([^\.]+)?'
 rext='\.?(.+)?'
 msec='_?([0-9]{0,3})'
 if is_string(delim) then tlim='\'+trim(delim) else tlim='_'
 slim2=tlim+'?'
 slim=tlim
 sregex='([^'+tlim+'\\/0-9]*)'+slim2+dyear+mons+days+slim+hrs+mins+secs+msec+$
        rest+rext
endelse

s=stregex(file,sregex,/sub,/extr,/fold)

dprint,sregex
np=n_elements(file)

times={year:0l,month:0l,day:0l,hour:0l,$
       minute:0l,second:0l,millisecond:0l}

ns=(size(s))[1]

times=replicate(times,np)
times.year=reform(s[2,*],np,/overwrite)
times.month=reform(s[3,*],np,/overwrite)
times.day=reform(s[4,*],np,/overwrite)
if ns gt 5 then times.hour=reform(s[5,*],np,/overwrite)
if ns gt 6 then times.minute=reform(s[6,*],np,/overwrite)
if ns gt 7 then times.second=reform(s[7,*],np,/overwrite)
if (ns gt 8) && keyword_set(msecs) then times.millisecond=reform(s[8,*],np,/overwrite)
if arg_present(extension) && (ns gt 10) then extension=comdim2(s[10,*])

;-- quick Y2K fix year

chk1=where(times.year le 50,count1)
if count1 gt 0 then times[chk1].year=times[chk1].year+2000l
chk2=where( (times.year gt 50) and (times.year lt 100) ,count2)
if count2 gt 0 then times[chk2].year=times[chk2].year+1900l

;-- flag "good" times

ss=where( (times.month gt 0) and (times.day gt 0),count)
if count eq 1 then ss=ss[0]

;-- extract YMD if desired

if arg_present(ymd) then begin
 ymd=string(times.year,'(i4)')+sep+string(times.month,'(i2.2)')+sep+$
      string(times.day,'(i2.2)')
 if keyword_set(short) then ymd=strmid(ymd,2,strlen(ymd[0]))
endif

names=reform(s[1,*],np,/overwrite)
if keyword_set(utc) then return,anytim2utc(times)
if keyword_set(tai) then return,anytim2tai(times)
if keyword_set(vms) then return,anytim2utc(times,/vms,truncate=truncate)
return,times

end

