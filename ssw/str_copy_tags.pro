function str_copy_tags, str1, str2, vercopy=vercopy
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
;	29-Sep-97 MDM - Patch to not crash when trying to copy a longer
;			input into an output
;       12-Mar-98 SLF - fix 'subscript w/-1' bug in 29-sep change
;       11-Mar-2003 - SLF - sprinle liberally with 'reform's sinc RSI
;                     screwed us with degenerate structure/vector dimensions
;                     circa IDL V5.5
;       15-apr-2003 - SLF - remove one of the 11-March reforms per Barry Labonte
;                     suggested - avoid problems at least on linux 5.6
;       16-may-2003 - SLF - change the syntax of the insertion string
;                     to explicitly match n-dimen of value
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
	i2 = (tag_index(str2,names1(i)))(0)
	qcopy = (i2 ne -1) and (1-is_member(names1(i),[skip_list,'SPARE'],/ignore_case))

	if (qcopy) then if n_elements(str2.(i2)) le n_elements(out.(i)) then $
                      out.(i)=str2.(i2)
    end else begin ;     else its a structure, so recurse
	i1 = (where(names2 eq names1(i)))(0)						;MDM added 4-Jan-94
	if (i1 ne -1) then begin 
           ; friggin RSI... starting w/IDL V5.5, have to wrap this in 
           ; an execute to protect against degenerate dimensions on insert...
           temp=str_copy_tags(reform([str1.(i)]),reform([str2.(i1)]),$
              vercopy=vercopy)
           insert_str='out.(i)'+arr2str(replicate('(0)',data_chk(temp,/ndim)),'')
           estring=insert_str+'=temp'
           estat=execute(estring)
if not estat then stop,'badexe'
        endif
    end
end
;
; return copied version
return, reform(out)
end
