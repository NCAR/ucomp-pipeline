function file2time, filearray, $
     yohkoh=yohkoh, ecs=ecs, ccsds=ccsds, out_style=out_style,quiet=quiet, $
     parse_timex=parse_timex,ymd=ymd
;-
;   Name: file2time
;
;   Purpose: convert filenames (...[YY]YYMMDD?HHMM[SS]...) -> time
;      
;   Input Parameters:
;      filearray - string array assumed to contain ....[YY]YYMMDD?HHMM[SS]...
;          
;   Keyword Parameters:
;      OUT_STYLE - Output Style - (ECS, CCSDS, YOHKOH, etc - see 'anytim.pro')
;      YOHKOH, ECS, CCSDS - explicit keywords to define OUT_STYLE
;      PARSE_TIME (switch) - if set, use dmzarro parse_time.pro 
;      DELIM - optional delimiter passed -> parse_time ; default='_'
;      YMD - year/month/day string returned from parse_time
;
;   Method: call extract_fid, anytim 
;
;   History:
;       28-mar-1997 - S.L.Freeland - broke out some 'extract_fid' logic, extend to YYYY...
;	18-Feb-1998 (MDM) - Modified to work on YYMMDD type of field (no
;			    HHMMSS portion)
;        9-Jun-1998, Zarro (SAC/GSFC) - return scalar output for scalar input
;       13-Aug-2000, Zarro (EIT/GSFC) - added /QUIET
;       13-Aug-2000, S.L.Freeland - merged divergent 12-Dec-1999 SLF change
;                    vectorized earlier y2k fix (file list spans 2000)
;       13-Jan-2003, S.L.Freeland - add /PARSE_TIMEX switch and function
;                                   (if set, use dmz parse_time.pro)
;       15-Jan-2003, S.L.Freeland - remove BAD keyword from parse_time call
;                    (since it is no longer defined)
;       20-Jan-2003 Zarro - passed out YMD from PARSE_TIME to save 
;                           recalculating it later
;      09-May-2003, William Thompson - Use ssw_strsplit instead of strsplit
;      04-Jun-2020, Kim Tolbert - Pass quiet to extract_fid
;
;   Restrictions:
;      On any given call, all input filenames should be same format
;-

verbose=1-keyword_set(quiet)
ymd=''

if not data_chk(filearray,/string) then begin
   message,/info,"Need FID/FILEID like    [yy]yymmdd?hhmm[ss]
   return,''
endif

case 1 of
  keyword_set(yohkoh): out_style='yohkoh'
  keyword_set(ecs): out_style='ecs'
  keyword_set(ccsds): out_style='ccsds'
  1-keyword_set(out_style): out_style='ccsds'     ; default
  else:                                           ; user OUT_STYLE
endcase

if keyword_set(parse_timex) then begin            ; let parse_time.pro do work
   pt_times=parse_time(filearray,delim=delim,ymd=ymd)
   retval=anytim(temporary(pt_times),out_style=out_style)
   return,retval                                          ; unstruct exit
endif

fidarray=extract_fid(filearray,/notime, quiet=~verbose)           ; extract_fid

nfid=n_elements(fidarray)
lengths=strlen(fidarray)

delim=strspecial(fidarray(0))      ; 1st is template
dpos=(where(delim,dcnt))(0)
if (dpos eq -1) and (lengths(0) ge 6) then dpos = lengths(0)		;MDM 18-Feb-98
if dpos lt 6  then begin
  if verbose then message,/info,"Expect at least YYMMDD[delimiter]HHMM..."
    return,''
endif


hhmmss=replicate('000000',nfid)
yymmdd=strmid(fidarray,0,dpos)
if dpos lt lengths(0) then  hhmmss=strmid(fidarray,dpos+1,6)

; make the fid->time conversion consistent (yy->yyyy, hhmm->hhmmss)
if strlen(hhmmss(0)) eq 4 then hhmmss=hhmmss+'00'
if strlen(yymmdd(0)) eq 6 then $
        yymmdd=(['19','20'])(fix(strmid(yymmdd,0,2)) lt 50) + yymmdd

fidtime =strmid(yymmdd,0,4)+'/'+strmid(yymmdd,4,2)+'/' + strmid(yymmdd,6,2) + $
   ' ' + strmid(hhmmss,0,2)+':'+strmid(hhmmss,2,2)+':' + strmid(hhmmss,4,2)

if not keyword_set(out_style) then out_style='ccsds'

times=anytim(fidtime, out_style=out_style)
;
; for certain string formats, suppress milliseconds
; (pending 'anytim.pro' update)
if is_member(out_style,'ecs,yohkoh',/ignore_case,/wc) then $
    times = ssw_strsplit(times,'.',/head)

if (data_chk(filearray,/nx) eq 0) and (n_elements(times) eq 1) then times=times(0)
return,times
end
