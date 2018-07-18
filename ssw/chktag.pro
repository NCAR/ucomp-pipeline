;+
; Project     :	SDAC
;
; Func Name   :	CHKTAG
;
; Purpose     : Check for presence of a particular tag in a structure
;
; Example     : check=chktag(stc,tag)
;
; Inputs      : STC  = structure name
;               TAG = tag name to check for
;
; Outputs     : 1 if present, 0 otherwise
;
; Keywords    : RECURSE = set to search recursively down nested structures
;               NEST = nested structure with matching tag (if /RECURSE)
;               VALUE = return true if tag matches this value
;
; Category    : Structure
;
; Written     :	Zarro (ARC) Oct 1993 - written
;               Zarro (ADNET) 6 Dec-2015 - added NEST and VALUE keywords
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;               
;-

function chktag,stc,tag,recurse=recurse,nest=nest,value=value

nest=null()

if is_blank(tag) || ~is_struct(stc) then begin
 pr_syntax,'chk=chktag,structure,tag_name [,/recurse,nest=nest,value=value]'
 return,0b
endif
   
recurse=keyword_set(recurse)
tags=tag_names(stc)
ntags=n_elements(tags)
look=where(strupcase(trim(tag)) eq tags,count)
if (count gt 0) && exist(value) then begin
 if stc(0).(look[0]) ne value then count=0
endif
 
if (count gt 0) then begin
 if recurse then nest=stc
 return,1b 
endif

if recurse then begin
 for i=0,ntags-1 do begin
  if is_struct(stc(0).(i)) then if chktag(stc(0).(i),tag,recurse=recurse,nest=nest,value=value) then return,1b 
 endfor
endif

return,0b
end


