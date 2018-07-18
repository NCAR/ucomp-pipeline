function gt_day, item0, header=header, string=string, spaces=spaces, $
		leadzero=leadzero, lower=lower, longmonth=longmonth, $
		fits=fits, y2k=y2k
;
;+
;NAME:
;	gt_day
;PURPOSE:
;	To extract the word corresponding to day and optionally
;       return a string variable for that item.  If the item passed is an
;       integer type, it is assumed to be the 7-element external representation
;       of the time.
;CALLING SEQUENCE:
;	x = gt_day(roadmap)
;	x = gt_day(index)
;	x = gt_day(index.sxt, /space)		;put single space before string
;	x = gt_day(index, space=3)		;put 3 spaces
;METHOD:
;	The input can be a structure or a scalar.  The structure can
;	be the index, or roadmap, or observing log.
;INPUT:
;	item	- A structure or scalar.  It can be an array.  
;                               (or)
;                The "standard" 7 element external representation
;                of time (HH,MM,SS,MSEC,DD,MM,YY)
;OPTIONAL KEYWORD INPUT:
;	string	- If present, return the string mnemonic (long notation)
;	spaces	- If present, place that many spaces before the output
;		  string.
;	leadzero - If present, put a leading zero for dates 1 thru 9
;	lower	- If present, have the characters after the lead character be in
;		  lower case.
;	longmonth - If present, then use the full length month name
;       fits    - If present, then use the old FITS slash format of the type DD/MM/YY (obsolete)
;	y2k	- If present, then use 4-digit years.  Ignored if /FITS is used.
;OUTPUT:
;	returns	- The day, a integer value or a string
;		  value depending on the switches used.  It is a vector
;		  if the input is a vector
;		  Sample String: 12-OCT-91
;OPTIONAL OUTPUT:
;       header  - A string that describes the item that was selected
;                 to be used in listing headers.
;HISTORY:
;	Written 13-Nov-91 by M.Morrison
;	 4-Jun-92 (MDM) - Added "leadzero" option
;	21-Oct-92 (MDM) - Added "lower" option
;	10-Mar-93 (MDM) - Added "longmonth" option
;	16-May-93 (MDM) - Modified to accept string time as input
;	27-May-93 (MDM) - Modified to handle years after 1999
;        4-Aug-95 (MDM) - Added /FITS keyword
;	14-Nov-97 (MDM) - Changed FOR loop to use long integer
;	07-Feb-2002, William Thompson, added keyword Y2K
;       26-Jan-2012 (Aki Takeda) - Modified to accept Hinode FITS headers.
;                       - fixed Y2K handling by adding /nomod to int2ex.
;        3-Feb-2012 (Aki T) - anytim2ints --> anytim(item,/ints)
;-
;
header = ' Date   '	;9 characters
mon_arr = ['??', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
if (keyword_set(lower)) then mon_arr = ['??', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
if (keyword_set(longmonth)) then mon_arr = ['??', 'January', 'February', 'March', 'April', 'May', 'June', 'July', $
                'August', 'September', 'October', 'November', 'December']

;
if keyword_set(y2k) then yearfmt = "i4.4)" else yearfmt = "i2.2)"
fmt = "(i2, '-', a, '-', " + yearfmt
if (keyword_set(leadzero)) then fmt = "(i2.2, '-', a, '-', " + yearfmt
if (keyword_set(fits)) then     fmt = "(i2.2, '/', i2.2, '/', i2.2)"
;
if (n_elements(item0) eq 0) then begin
    message, 'Input variable ITEM not defined', /info
    tbeep, 5
    return, 0
end else begin
    item = item0
end
;
siz = size(item)
typ = siz( siz(0)+1 )
if (typ eq 7) then item = anytim(item,/ints)
;
siz = size(item)
typ = siz( siz(0)+1 )
if (typ eq 8) then begin
      tags = tag_names(item)
      case 1 of
      (tags(0) eq 'GEN') : out = item.gen.day       ; Yohkoh XDA index
      (tags(0) eq 'SIMPLE') and tag_exist(item,'telescop') : $ 
           if item(0).telescop eq 'HINODE' then begin    ; Hinode FITS
                 work = anytim(item.date_obs,/ints)
                 out = work.day
           endif else out = item.day                     ; Yohkoh FITS 
      else : out = item.day                        ; originally string 
      endcase
      qstruct = 1
endif else begin
      out = item          ;save in case the /string option was not used
      qstruct = 0
endelse
;
if (keyword_set(string) or keyword_set(spaces) or keyword_set(y2k)) then begin
    if (not qstruct) then tarr = item else $            ;they passed in the 7-element time array
	int2ex, intarr(n_elements(out))+1, [out], tarr,/nomod        ;do not want to mess with "time" so convert to "external"
		;have to change out to an array because of trouble with int2ex
    ;
    siz = size(tarr)
    if ((not qstruct) and ((siz(1) eq 1) or (siz(0) eq 0))) then begin
	int2ex, intarr(n_elements(out))+1, [out], tarr,/nomod
	siz = size(tarr)
    end
    n = 1
    if (siz(0) eq 2) then n = siz(2)
    out = strarr(n)
    ;for i=0,n-1 do out(i)  = string(tarr(4,i), mon_arr(tarr(5,i)), tarr(6,i), format=fmt)
    year = tarr(6,*)
    if (not keyword_set(y2k)) or keyword_set(fits) then year = year mod 100
    if (keyword_set(fits)) then begin	;DD/MM/YY
	for i=0L,n-1 do out(i)  = string(tarr(4,i),          tarr(5,i), year(i), format=fmt)	;MDM 27-May-93
    end else begin
	for i=0L,n-1 do out(i)  = string(tarr(4,i), mon_arr(tarr(5,i)), year(i), format=fmt)	;MDM 27-May-93
    end
    ;
    if (keyword_set(spaces)) then begin
        sp = string(replicate(32b, spaces))
        out = sp + out
        header = sp + header
    end

    if (n eq 1) then out=out(0)		;change to a scalar
end
;
return, out
end
