;+
;   Name: fix_slash
;
;   Purpose: return string with slashes corrected for OS
;
;   Input Parameters:
;      source - source string
;
; Category    :
;	Utilities, Strings
;
;   History: Kim Tolbert, 26-Jul-2001
;
;-
;


function fix_slash, source

local_delim = get_delim()
out = str_replace (source, '/', local_delim)
out = str_replace (out, '\', local_delim)

return, out
end
