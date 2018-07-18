;+
;       NAME: data_type
;
;       PURPOSE: Return the data type code from SIZE
;
;       CALLING SEQUENCE: type=data_type(data)
;
;       HISTORY: Drafted by A.McAllister, 8-jul-93.
;
;-
FUNCTION data_type,data

sz=size(data)

return,sz(n_elements(sz)-2)

end