function gt_res, item, string=string, short=short, header=header, spaces=spaces, original=original
;
;+
;NAME:
;	gt_res
;PURPOSE:
;	To extract the bits corresponding to image resolution and optionally
;	return the string nemonic for that resolution
;CALLING SEQUENCE:
;	print, gt_res()			;print full listing of resolutions
;	res = gt_filta(res)
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
;	short	- If present, return the short string nemonic 
;	spaces	- If present, place that many spaces before the output
;                 string.
;       original - If set, return the original corner commanded (from index.sxt)
;OUTPUT:
;	returns	- The resolution selected, a integer value or a string
;		  value depending on the switches used.  It is a vector
;		  if the input is a vector
;OPTIONAL OUTPUT:
;	header	- A string that describes the item that was selected
;		  to be used in listing headers.
;HISTORY:
;	Written 7-Nov-91 by M.Morrison
;	13-Nov-91 MDM - Added "header" and "spaces" option
;	15-Nov-91 MDM - Changed short notation from 1x1, 2x2, 4x4 to
;			FR, HR, QR
;	10-Jun-93 (MDM) - Added option to extract from the history structure
;	17-Jun-93 (MDM) - Added /ORIGINAL option
;	07-May-2008 (Aki Takeda) - Modified to accept YLA FITS headers.
;	06-May-2009 (Aki T) - Modification on FITS header input: return the 
;                      value of header.pixel_si, instead of header.imgparam
;                      when the keyword, /orig is not set.
;	19-May-2009 (Aki T) - handle the case with header.pix_size, and 
;                      the case without header.pixel_si nor header.pix_size.
;	02-Jun-2009 (Aki T) - corrected a bug (XDA handling part). 
;-
;
head_long = 'Res '
head_short = 'Rs'
conv2str = ['Full', 'Half', 'Qrtr', '????']	;4 characters
conv2short = ['FR', 'HR', 'QR', '??']		;2 characters
;
if (n_params(0) eq 0) then begin
    print, 'String Output for GET_RES'
    for i=0,2 do print, i, conv2str(i), conv2short(i), format='(i3, 2x, a6, 2x, a6)'
    return, ''
end
;
siz = size(item)
typ = siz( siz(0)+1 )
if (typ eq 8) then begin
    ;Check to see if an index was passed (which has the "periph" tag
    ;nested under "sxt", or a roadmap or observing log entry was
    ;passed
    tags = tag_names(item)
    case 1 of
     (tags(0) eq 'GEN') : if (his_exist(item) and (not keyword_set(original))) $
		                 then out = item.his.pixel_size     $
			         else out = item.sxt.imgparam
     (tags(0) eq 'SIMPLE') : $
               if keyword_set(original) $  ; FITS header (7-May-2008)
                     then out = item.imgparam          $
;                     else out = fix(item.pixel_si)   ; (6-May-2009)
                     else begin                      ; (19-May-2009)
                           case 1 of
                            tag_exist(item,'pix_size') : out = fix(item.pix_size) 
                            tag_exist(item,'pixel_si') : out = fix(item.pixel_si)
                            else : out=mask(round(item.cdelt1/2.455),1,2)
                           endcase
                     endelse
      else : out= item.imgparam    ;roadmap
    endcase
end else begin
    out = item
end
;
;---- If the item passed is byte type, then assume that it is a
;     raw telemetered value and the item's bits need to be extracted
siz = size(out)
typ = siz( siz(0)+1 )
if (typ eq 1) then out = mask(out, 0, 2)	;if it is byte type - then mask
out = out>0<3	;check range
;
out = gt_conv2str(out, conv2str, conv2short, header_array, header=header, $
        string=string, short=short, spaces=spaces)

;
return, out
end
