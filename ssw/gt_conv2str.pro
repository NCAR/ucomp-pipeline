function gt_conv2str, item, str_long, str_short, header_array, $
		header=header, $
		string=string, short=short, spaces=spaces, fmt=fmt
;
;+
;NAME:
;	gt_conv2str
;PURPOSE:
;	After a "GT" routine has extracted the relevant information, optionally
;	convert the information to a string.
;METHOD:
;INPUT:
;	item	- An integer scalar or array.  Any check on it's proper range
;		  should have been done in the calling routine.
;	str_long
;	str_short
;	header_array - A list of the header strings available.
;			header_array(0) - used by /string and /fmt 
;					  and /spaces options
;			header_array(1) - used by /short option
;OPTIONAL INPUT:
;	string	- If present, return the string nemonic for the
;		  filter (long notation)
;	short	- If present, return the short string nemonic for
;		  the filter
;	spaces	- If present, place that many spaces before the output
;		  string.  The long notation is used unless /short
;		  is specified.
;	fmt	- Format statement to be used if /string, /short, or
;		  /spaces option is used.
;OUTPUT:
;	returns	- If requested to make a conversion, then return the string
;		  equivalent of the input.  It is a vector
;		  if the input is a vector
;OPTIONAL OUTPUT:
;       header  - A string that describes the item that was selected
;                 to be used in listing headers.
;HISTORY:
;	Written 13-Nov-91 by M.Morrison
;	 3-Jun-93 (MDM) - Modified to use a LONG variable for the for loop
;-
;
nh = n_elements(header_array)
if (nh eq 0) then header_array = [' ', ' ']
qstring = (keyword_set(string) or keyword_set(short) or keyword_set(spaces))
qshort = keyword_set(short)
;
out = item
if (qstring) then begin
    if (keyword_set(fmt)) then begin		;first check if specific format statement
	;;out = string(item, format=fmt)
	;--- Trouble with IDL makes the following necessary
	;    The problem is that "xx=string(intarr(1000))" gives a strarr of 1000 elements, but
	;    "xx=string(intarr(1000), format=fmt)" only returns a 128 element strarr
	n = n_elements(out)
	nloops = n/100
	if ((n mod 100) ne 0) then nloops = nloops + 1
	for i=0L,nloops-1 do begin
	    ist = i*100
	    ien = (ist+99)<(n-1)
	    temp = string(item(ist:ien), format=fmt)
	    if (i eq 0) then out = temp else out = [out, temp]
	end
	header = header_array(0)
    end else if (keyword_set(qshort)) then begin
	out = str_short(item)
	header = header_array(1<(nh-1)>0)	;sometimes only one header is passed
    end else begin				;/string and /spaces options
	out = str_long(item)
	header = header_array(0)
    end
    ;
    if (keyword_set(spaces)) then begin
	sp = string(replicate(32b, spaces))
	out = sp + out
	header = sp + header
    end
end
;
;TODO - check that header length equals item length
;
return, out
end
