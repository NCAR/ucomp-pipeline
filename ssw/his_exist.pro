function his_exist, index
;
;+
;NAME:
;	his_exist
;PURPOSE:
;	Simple function to see if the history structure (.HIS) exists 
;	in the index
;SAMPLE CALLING SEQUENCE:
;	q = his_exist(index)
;INPUT:
;	index	- The index structure
;OUTPUT:
;	returns 0 if the structure does not exist, 1 if it does
;HISTORY:
;	Written 6-Jun-93 by M.Morrison
;
siz = size(index)
typ = siz( siz(0)+1 )
if (typ ne 8) then begin
    message, 'Input must be of structure type', /info
    return, 0
end
;
tags = tag_names(index)
ss = where(strpos(tags, 'HIS') ne -1, out)
return, out
end
