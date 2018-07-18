;+
; Project     : HESSI
;
; Name        : LOCAL_NAME
;
; Purpose     : convert input file name into local OS
;
; Category    : system string
;                   
; Inputs      : INFIL = filename to convert
;                       [e.g. /ydb/ys_dbase]
;
; Outputs     : OUTFIL = filename with local OS delimiters 
;                        [e.g. \ydb\yd_dbase - if Windows]
;
; Keyword     : NO_EXPAND = don't expand environment variable
;
; History     : 29-Dec-2001,  D.M. Zarro (EITI/GSFC) - Written
;               9-Feb-2004, Zarro (L-3Com/GSFC) - added /NO_EXPAND
;               15-Jan-2015, Zarro (ADNET) 
;               - added check for scalar input
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function local_name,infil,no_expand=no_expand

if n_elements(infil) eq 0 then return,''
if ~is_string(infil) or (n_elements(infil) gt 1) then return,infil

blim=(byte(get_delim()))[0]

temp=byte(infil)
bslash=(byte('/'))[0]
bbslash=(byte('\'))[0]
chk=where( (temp eq bslash) or (temp eq bbslash),count)
if count gt 0 then temp[chk]=blim

temp=string(temp)
if keyword_set(no_expand) then return,temp

temp_new=chklog(temp,/pre)

;-- do second pass to convert environment variable

if temp_new[0] ne temp[0] then temp_new=local_name(temp_new,/no_expand)

return,temp_new

end
