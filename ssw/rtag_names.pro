;+
; Project     : SOHO - CDS
;
; Name        : RTAG_NAMES
;
; Category    : structures
;
; Purpose     : recursively return all tag names within a structure
;
; Syntax      : IDL> tags=rtag_names(struct)
;
; Inputs      : STRUCT = structure to check
;
; Outputs     : TAGS = tag names
;
; Keywords    : STRUCTURE_NAME: set for structure name
;
; History     : 23-Sept-2000,  D.M. Zarro (EIT/GSFC), Written
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function rtag_names,struct,structure_name=structure_name

sz=size(struct)
stype=sz(n_elements(sz)-2)
if stype ne 8 then return,''

if keyword_set(structure_name) then return,tag_names(struct,/structure_name)
ntags=n_tags(struct)
tags=tag_names(struct)
for i=0,ntags-1 do begin
 rtags=rtag_names(struct.(i))
 if rtags(0) ne '' then tags=[tags,rtags]
endfor

return,tags
end



