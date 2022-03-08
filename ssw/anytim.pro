;
;+
;NAME:
;	anytim
;PURPOSE:
;       Given a time in the form of a (1) structure, (2) 7-element time
;       representation, or (3) a string representation, or (4) an array
;       2xN where the first dimension holds (MSOD, DS79), or 
;	(5) a double or float array of seconds from 1-jan-79
;	convert to  any of the 5 representations including both varieties
;	of strings, dd-mon-yr or yy/mm/dd.
;CALLING SEQUENCE:
;	xx = anytim(roadmap, out_styl='ints')
;	xx = anytim("12:33 5-Nov-91", out_sty='ex')
;	xx = anytim([0, 4000], out_style= 'sec')
;INPUT:
;	item	- The input time
;		  Form can be (1) structure with a .time and .day
;		  field, (2) the standard 7-element external representation
;		  or (3) a string of the format "hh:mm dd-mmm-yy"
;		  or (4) 2xN where the first dimension holds (MSOD, DS79), or 
;		  or (5) a double or float array of seconds from 1-jan-79
;
;OPTIONAL KEYWORD INPUT:
;	out_style - Output representation, specified by a string:
;      		INTS   	- structure with [msod, ds79]
;		STC     - same as INTS
;      		2XN    	- longword array [msod,ds79] X N
;      		EX     	- 7 element external representation (hh,mm,ss,msec,dd,mm,yy)
;		UTIME	- Utime format, Real*8 seconds since 1-jan-79, DEFAULT!!!!
;               SEC     - same as Utime format
;               SECONDS - same as Utime format
;		ATIME   - Variable Atime format, Yohkoh
;			  Yohkoh style - 'dd-mon-yy hh:mm:ss.xxx'   or
;			  HXRBS pub style  - 'yy/mm/dd, hh:mm:ss.xxx'
;			  depending on atime_format set by 
;			  hxrbs_format or yohkoh_format
;		YOHKOH  - yohkoh style string 
;		HXRBS   - HXRBS Atime format /pub, 'yy/mm/dd, hh:mm:ss.xxx'
;               YY/MM/DD- same as HXRBS
;	or by keywords
;		/ints   - 
;	        /stc
;		/_2xn
;		/external
;		/utime
;		/seconds
;		/atimes
;		/yohkoh
;		/hxrbs
;		/yymmdd	
;	mdy	- If set, use the MM/DD/YY order for converting the string date
;		
;	date 	- return only the calendar date portion, 
;			e.g. anytime('93/6/1, 20:00:00',/date,/hxrbs) ==> '93/06/01'
;	time    - return only the time of day portion
;			e.g. anytime('93/6/1, 20:00:00',/date,/hxrbs) ==> '20:00:00.000'
;keyword output:
;	error	- set if an error, dummy for now, ras 18-Nov-93
;restrictions:
;	one dimensional or scalar longwords will be interpreted as
;	double precision seconds unless they have either two or seven
;	elements
;HISTORY:
;	Written 31-Oct-93 ras
;	modified 4-jan-94 ras, made argument recognition more robust
;		also made output dimensions similar for /yohkoh  and /hxrbs
;	modified 25-jan-94 ras, made SEC or SECONDS work
;	ras 30-jan-94, fixed string outputs for /date and /time
;-
;

function anytim, item, out_style=out_style, mdy=mdy, $
	ints=ints, stc=stc, _2xn=_2xn, external=external, utime=utimes, $
	seconds=sec, atimes=atimes,yohkoh=yohkoh,  hxrbs=hxrbs, yymmdd=yymmdd, $
	date=date, time=time, error=error

on_error, 2
error = 1			;ras 18-nov-93; tbd
;error checking on EX vector
;ex is hh,mm,ss,msec,dd,mm,yy
exrange= reform( [0,23,0,59,0,59,0,999,1,31,1,12,0,99], 2,7)

siz = size(item)
if siz(0) eq 0 then scalar = 1 else scalar =0
typ = datatype(item(0))
;Convert to EX representation

case 1 of
 (typ eq 'STC'): int2ex, gt_time(item), gt_day(item), ex

 (typ eq 'DOU' or typ eq 'FLO') or $
 ( (typ eq 'INT' or typ eq 'LON') and ( (n_elements(item) eq 1) or $ 
 (siz(0) eq 1 and (siz(1) ne 2 and siz(1) ne 7)))):  begin
;	ustr = utime2str( item, utbase=0.0) 
	ustr = utime2str( item(*), utbase=0.0)  ;ras, 4-jan-94
	int2ex, ustr.time, ustr.day, ex
 end

 (typ eq 'INT' or typ eq 'LON' and n_elements(item) ge 2): begin
	case siz(1) of
		7: ex = item 
		2: int2ex, item(0,*), item(1,*), ex
	        else: begin
			Print, 'Not a valid input to Anytim! Error!'
			goto, error_out 
		      end
	endcase
 end

 (typ eq 'STR'): begin
	if keyword_set(mdy) then begin; Special format!
		wyo_count = n_elements(item)
		wno_count = 0
		wyohkoh= indgen(wyo_count)
	endif else begin
		test = strpos(item,'-') ne -1  
		wyohkoh = where( test, wyo_count)
		wnot    = where( test ne 1, wno_count)
	endelse

;Interpret all Yohkoh strings,
;	Although Utime will support simple Yohkoh strings,
;	it doesn't support reverse order and 4 digits for the year, ie 1993
;	For the moment, 1-Nov-93, all Yohkoh strings interpreted here

	if wyo_count ge 1 then begin
		ex1 = timstr2ex( item( wyohkoh ),mdy=mdy )
;Check for errors in Yohkoh string interpretation
		for i=0,6 do begin
        		out_of_range= where( ex1(i,*) lt exrange(0,i) or ex1(i,*) gt $
                		exrange(1,i), num_out)
	        	if num_out ge 1 then begin
				Print, 'Error in Yohkoh string interpretation out of Timstr2ex,'
				Print, 'Could not interpret - ',(item(wyohkoh))(out_of_range)
				Print, 'Correct input format:'
				Print, '4-Jan-91 22:00:15.234, range is 1-jan-(19)50 to 31-dec-(20)49'
				goto, error_out
			endif
		 endfor
	endif


;Interpret HXRBS style strings and strings w/o dates, 'yy/mm/dd, hh:mm:ss.xxx'
	if wno_count ge 1 then begin
		ut = utime( item(wnot), error=error_utime ) 		;not yet if ever, mdy=mdy )
		if error_utime then begin
			Print, 'Error in HXRBS string interpretation by Utime'
			Print, 'Could not interpret - ',(item(wnot))(0)
			Print, 'Correct input format:'
			Print, '89/12/15, 22:00:15.234, range is 1-jan-(19)50 to 31-dec-(20)49'
			goto, error_out
			Print,'goto, error_out
		endif
		ustr= utime2str(ut, utbase = 0.0)
		int2ex, ustr.time, ustr.day, ex2
	endif
	
	if wyo_count eq 0 then ex = ex2 else $
	if wno_count eq 0 then ex = ex1 else ex=[ex1,ex2]
  end
  1: begin
	Print, 'Not a valid input to Anytim! Error!'
	goto, error_out 
     end
endcase

wcount = n_elements(ex) / 7

case 1 of
	keyword_set(date): $
	if wcount eq 1 then ex(0:3) = 0 else ex(0:3,*) = 0 
	keyword_set(time): $
	if wcount eq 1 then ex(4:6) = [1,1,79] else ex(4:6,*) = rebin([1,1,79],3,wcount) 
	1: ;NOACTION
endcase

;Now we have the time in the 7xN external format, Choose the output!

checkvar, out_style, 'UTIME'

out = strupcase(out_style)

if keyword_set(utimes) then out = 'UTIME'
if keyword_set(sec) then out = 'SEC'
if keyword_set(atimes) then out = 'ATIME'
if keyword_set(external) then out = 'EX'
if keyword_set(ints) then out = 'INTS'
if keyword_set(stc) then out = 'STC'
if keyword_set(_2xn) then out = '2XN'
if keyword_set(hxrbs) then out = 'HXRBS'
if keyword_set(yymmdd) then out = 'YY/MM/DD'
if keyword_set(yohkoh) then out = 'YOHKOH'

if out eq  'UTIME' or out eq 'SEC' or out eq 'SECONDS' then begin 
	result = int2sec( anytim2ints( ex ) )
	if (typ eq 'DOU' or typ eq 'FLO' or typ eq 'STR') then $
        result = double(strmid(item,0,0)+'0') + result
endif

if out eq 'EX' then result = ex

if out eq 'INTS' or out eq 'STC' then result = anytim2ints( ex )

if out eq '2XN' then begin 
	result = anytim2ints(ex)
	result = transpose( [[result.time],[result.day]] )
endif

if out eq 'ATIME' then begin
	result = atime(/pub, ex, date=date, time=time)
endif

if out eq 'YOHKOH' then begin
	result = atime(/yohkoh, ex, date=date, time=time) 
	if (typ eq 'DOU' or typ eq 'FLO' or typ eq 'STR') then $ ;ras, 4-jan-94
	result = strmid(item,0,0) + result
endif
                                                                              
if out eq 'HXRBS' or out eq 'YY/MM/DD' then begin
	result = int2sec( anytim2ints( ex ) )
	result = atime( result,/hxrbs,/pub,date=date, time=time )
	if (typ eq 'DOU' or typ eq 'FLO' or typ eq 'STR') then $
	result = strmid(item,0,0) + result
endif
if scalar and n_elements(result) eq 1 then result= result(0)

	

error = 0
return, result
error_out: return, item

end

