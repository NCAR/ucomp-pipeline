function str_copy_tags, str1, str2, vercopy=vercopy
;
;+
;   Name: str_copy_tags
;
;   Purpose: copy structures where the tag names match.  The
;	     default is NOT to copy the tags "index_version"
;	     and "entry_type"
;
;   Input Parameters:
;      str1 - destination structure (template)
;      str2 - source structure
;   Optional Input:
;	vercopy - If present, then the keywords "index_version" and
;		    "entry_type" are not copied (to preserve the
;		    new structure version number)
;
;   Output: function return value is type str1 copy of str2 contents
;
;   History: slf, 10/24/91
;	     slf, 10/24/91 - streamlined recursive segment
;	     mdm, 11/10/91 - took "str_copy" and made it copy by
;			     matching tag names
;	12-Nov-91 MDM - Added "spare1" and "spare2" to the skip-list
;	18-Dec-92 MDM - Added code to avoid copying any SPARE tags all the
;			time (not just if /vercopy is set)
;	 4-Jan-94 MDM - Modified so that it will work if passing in
;			an index with .GEN, .SXT, and .HIS and the other
;			structure just has .GEN and .SXT.
;		      - Previously, the input structure was being modified.
;			Made changes to not corrupt the input template
;	
;
;   Method: recursive for nested structures
;-
;
;--- The following is a list of the tag names that will NOT be
;    copied (unless the default is overwritten by the /VERCOPY
;    option)
;
skip_list = ['INDEX_VERSION', 'ENTRY_TYPE', 'SPARE', 'SPARE1', 'SPARE2']
						;avoid copying spare since the size will probably not match
;
out = str1	;mdm added 4-Jan-94
if (n_elements(str1) eq 1) and (n_elements(str2) ne 1) then out = replicate(out, n_elements(str2))	;mdm added 4-Jan-94
;
names1 = tag_names(str1)	;use the destination structure as the
				;source of tag names
names2 = tag_names(str2)
for i=0,n_tags(str1)-1 do begin  
    if (n_tags(str1.(i)) eq 0) then begin
	ss = where(names2 eq names1(i))		;look for where "str2" has the same tag name as "str1"
	i2 = ss(0)
	qcopy = 0
	if (i2 ne -1) then qcopy = 1
	ss = where(skip_list eq names1(i))
	if ((ss(0) ne -1) and (not keyword_set(vercopy))) then qcopy = 0	;if found this item on the "skip list"
										;and not told to override the default
										;(not to copy the "skip list" items)
	if (strmid(names1(i), 0, 5) eq 'SPARE') then qcopy = 0		;avoid all spare
	if (qcopy) then out.(i)=str2.(i2) 
    end else begin ;     else its a structure, so recurse
	i1 = (where(names2 eq names1(i)))(0)						;MDM added 4-Jan-94
	if (i1 ne -1) then out.(i)=str_copy_tags(str1.(i),str2.(i1), vercopy=vercopy)	;MDM added 4-Jan-94
	;; str1.(i)=str_copy_tags(str1.(i),str2.(i))
    end
end
;
; return copied version
return, out
end
