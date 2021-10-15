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
;
; :Keywords:
;   valid_range : in, optional, type=fltarr(2)
;     valid range for `value`, returns 'NULL' if `value` is outside this range
;-
function ucomp_db_float, value, valid_range=valid_range
  compile_opt strictarr

  if (n_elements(value) eq 0L || ~finite(value)) then return, 'NULL'
  if (n_elements(valid_range) gt 0L) then begin
    if (value le valid_range[0] || value gt valid_range[1]) then return, 'NULL'
  endif

  return, string(value, format='(%"%f")')
end
