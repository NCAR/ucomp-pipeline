; docformat = 'rst'

;+
; Increment a date in form "YYYYMMDD" by one day.
;
; :Returns:
;   string of the form "YYYYMMDD"
;
; :Params:
;   date : in, required, type=string
;     date in the form "YYYYMMDD"
;-
function ucomp_increment_date, date
  compile_opt strictarr

  date_parts = long(ucomp_decompose_date(date))
  jd = julday(date_parts[1], date_parts[2] + 1L, date_parts[0])
  return, string(jd, '(C(CYI4.4,CMOI2.2,CDI2.2))')
end
