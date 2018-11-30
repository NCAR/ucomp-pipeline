; docformat = 'rst'

;+
; Decompose a date string into year, month, day.
;
; :Returns:
;   `strarr(3)`
;
; :Params:
;   date : in, required, type=string
;     date in the form 'YYYYMMDD'
;-
function ucomp_decompose_date, date
  compile_opt strictarr

  year  = strmid(date, 0, 4)
  month = strmid(date, 4, 2)
  day   = strmid(date, 6, 2)

  return, [year, month, day]
end
