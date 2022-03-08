function gt_time, item0, header=header, string=string, spaces=spaces, msec=msec, nolead0=nolead0
;
;+
;NAME:
;	gt_time
;PURPOSE:
;	To extract the word corresponding to time and optionally
;	return a string variable for that item.  If the item passed is an
;	integer type, it is assumed to be the 7-element external representation
;	of the time.
;CALLING SEQUENCE:
;	x = gt_time(roadmap)
;	x = gt_time(index)
;	x = gt_time(index.sxt, /space)		;put single space before string
;	x = gt_time(index, space=3)		;put 3 spaces
;METHOD:
;	The input can be a structure or a scalar.  The structure can
;	be the index, or roadmap, or observing log.
;INPUT:
;	item	- A structure or scalar.  It can be an array.  
;				(or)
;                The "standard" 7 element external representation
;                of time (HH,MM,SS,MSEC,DD,MM,YY)
;OPTIONAL INPUT:
;	string	- If present, return the string mnemonic (long notation)
;	spaces	- If present, place that many spaces before the output
;		  string.
;	msec	- If present, also print the millisec in the formatted 
;		  output.
;	nolead0	- If present, do not include a leading "0" on the hour string
;		  for hours less than 10. (ie: return 9:00:00 instead of 09:00:00)
;OUTPUT:
;	returns	- The time, a integer value or a string
;		  value depending on the switches used.  It is a vector
;		  if the input is a vector
;                 Sample String: 23:25:10
;OPTIONAL OUTPUT:
;       header  - A string that describes the item that was selected
;                 to be used in listing headers.
;HISTORY:
;	Written 13-Nov-91 by M.Morrison
;	15-Nov-91 (MDM) - Added "msec" and "nolead0" options.  Made the default
;		 	  different from before for leading 0 (it will have a leading
;			  zero unless the /nolead0 option is used)
;       16-May-93 (MDM) - Modified to accept string time as input
;-
;
header = ' Time  '	;8 characters
if (keyword_set(msec)) then header = header + '    '	;four extra characters with msec option
;
if (n_elements(item0) eq 0) then begin		;added 16-May-93
    message, 'Input variable ITEM not defined', /info
    tbeep, 5
    return, 0
end else begin
    item = item0
end
;
siz = size(item)
typ = siz( siz(0)+1 )
if (typ eq 7) then item = anytim2ints(item)
;
siz = size(item)
typ = siz( siz(0)+1 )
if (typ eq 8) then begin
    tags = tag_names(item)
    if (tags(0) eq 'GEN') then out = item.gen.time $
			else out = item.time
    qstruct = 1
end else begin
    out = item						;save in case the /string option was not used
    qstruct = 0
end
;
if (keyword_set(string) or keyword_set(spaces)) then begin
    if (not qstruct) then tarr = item else $		;they passed in the 7-element time array
		int2ex, [out], intarr(n_elements(out))+1, tarr	;do not want to mess with "day" so convert to "external" 
                ;have to change out to an array because of trouble with int2ex
    ;
    siz = size(tarr)
    if ((not qstruct) and ((siz(1) eq 1) or (siz(0) eq 0))) then begin	;copied from GT_DAY 16-May-93
        int2ex, intarr(n_elements(out))+1, [out], tarr
        siz = size(tarr)
    end
    n = 1
    if (siz(0) eq 2) then n = siz(2)
    out = strarr(n)
    fmt="(i2.2, ':', i2.2, ':', i2.2)"
    if (keyword_set(nolead0)) then fmt = "(i2, ':', i2.2, ':', i2.2)"
    for i=0,n-1 do begin
	out(i) = string(tarr(0:2,i), format=fmt)
	if (keyword_set(msec)) then out(i) = out(i) + '.' + string(tarr(3,i), format='(i3.3)')
    end
    ;
    if (keyword_set(spaces)) then begin
        sp = string(replicate(32b, spaces))
        out = sp + out
        header = sp + header
    end
    ;
    if (n eq 1) then out=out(0)         ;change to a scalar
end
;
return, out
end
