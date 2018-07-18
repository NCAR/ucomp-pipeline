function gt_filta, item, header=header, string=string, short=short, spaces=spaces
;
;+
;NAME:
;	gt_filta
;PURPOSE:
;	To extract the bits corresponding to Filter-A and optionally
;	return a string mnemonic.
;CALLING SEQUENCE:
;	print, gt_filta()			;to list the nemonics
;	filta = gt_filta(index)
;	filta = gt_filta(roadmap)
;	filta = gt_filta(index.sxt, /string)
;	filta = gt_filta(filta, /short)
;	filta = gt_filta(indgen(6)+1)		;used with menu selection
;	filta = gt_filta(index.sxt, /space)	;put single space before string
;	filta = gt_filta(index.sxt, space=3)	;put 3 spaces
;METHOD:
;	The input can be a structure or a scalar.  The structure can
;	be the index, or roadmap, or observing log.  If the input
;	is non-byte type, it assumes that the bit extraction had
;	already occurred and the "mask" is not performed on the input.
;INPUT:
;	item	- A structure or scalar.  It can be an array.  If this
;		  value is not present, a help summary is printed on the
;		  filter names used.
;OPTIONAL INPUT:
;	string	- If present, return the string mnemonic (long notation)
;	short	- If present, return the short string mnemonic 
;	spaces	- If present, place that many spaces before the output
;		  string.
;OUTPUT:
;	returns	- The filter selected, a integer value or a string
;		  value depending on the switches used.  It is a vector
;		  if the input is a vector
;OPTIONAL OUTPUT:
;       header  - A string that describes the item that was selected
;                 to be used in listing headers.
;HISTORY:
;	Written 7-Nov-91 by M.Morrison
;       13-Nov-91 MDM - Added "header" and "spaces"  option
;       1-Feb-2007 Aki Takeda - Modification to accept YLA FITS headers as input. 
;-
;
header_array = ['FiltA', 'FA']
conv2str = ['???  ', 'Open ', 'NaBan', 'Quart', 'Diffu', 'WdBan', 'NuDen', '???  ']	;5 characters
conv2short = ['??', 'Op', 'NB', 'Qz', 'Df', 'WB', 'ND', '??']				;2 Characters
;
if (n_params(0) eq 0) then begin
    print, 'String Output for GET_FILTA'
    for i=1,6 do print, i, conv2str(i), conv2short(i), format='(i3, 2x, a6, 2x, a6)'
    return, ''
end
;
siz = size(item)
typ = siz( siz(0)+1 )
if (typ eq 8) then begin
    ;Check to see if an index was passed (which has the "periph" tag
    ;nested under "sxt", or a roadmap or observing log entry was passed
    tags = tag_names(item)
    if (tags(0) eq 'GEN') then out = item.sxt.periph $
			else out = item.periph
    if (tags(0) eq 'SIMPLE') then out = mask(out, 0, 3)  ; for FITS header 
end else begin
    out = item
end
;
;---- If the item passed is byte type, then assume that it is a
;     raw telemetered value and the item's bits need to be extracted
siz = size(out)
typ = siz( siz(0)+1 )
if (typ eq 1) then out = mask(out, 0, 3)
out = out>0<7	;check the range
;
out = gt_conv2str(out, conv2str, conv2short, header_array, header=header, $
	string=string, short=short, spaces=spaces)
;
return, out
end
