; docformat = 'rst'

;+
; Convert a floating point value to a string in a suitable form for entering
; into a SQL database. Notably, convert NaN, Inf, and `!null` to "NULL" string.
;
; :Returns:
;   string
;
; :Params:
;   value : in, optional, type=float
;     value to convert, may be NaN, Inf, or not present, in which case it will
;     be converted to "NULL"
;-
function ucomp_db_float, value
  compile_opt strictarr

  if (n_elements(value) eq 0L || ~finite(value)) then return, 'NULL'
  return, string(value, format='(%"%f")')
end
