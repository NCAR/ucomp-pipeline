; docformat = 'rst'

;+
; Parse a date expression to find the dates given. Expressions can list dates
; with a comma::
;
;   20180101,20180103
;
; or specify ranges with a hyphen::
;
;   20180101-20180201
;
; Note the start date is inclusive and the end date is exclusive. So
; '20180101-20180201' specifies all the dates in January 2018.
;
; :Examples:
;   For example::
;
;     IDL> expr = '20170101-20170201,20180101,20180501-20180514'
;     IDL> days = ucomp_parse_dateexpr(expr, count=n_days)
;     IDL> print, expr, n_days, format='(%"%s -> %d days")'
;     20170101-20170201,20180101,20180501-20180514 -> 45 days
;     IDL> print, days
;     20170101 20170102 20170103 20170104 20170105 20170106 20170107 20170108
;     20170109 20170110 20170111 20170112 20170113 20170114 20170115 20170116
;     20170117 20170118 20170119 20170120 20170121 20170122 20170123 20170124
;     20170125 20170126 20170127 20170128 20170129 20170130 20170131 20180101
;     20180501 20180502 20180503 20180504 20180505 20180506 20180507 20180508
;     20180509 20180510 20180511 20180512 20180513
;
; :Returns:
;   strarr of dates of the form 'YYYYMMDD'
;
; :Params:
;   expr : in, required, type=str
;     date expression to parse
;
; :Keywords:
;   count : out, optional, type=long
;     set to a named variable to retrieve the number of days returned
;-
function ucomp_parse_dateexpr, expr, count=count
  compile_opt strictarr
  on_error, 2

  _expr = strcompress(expr, /remove_all)

  dates = !null
  count = 0L

  range_exprs = strsplit(_expr, ',', /extract, count=n_range_exprs)

  for r = 0L, n_range_exprs - 1L do begin
    endpts = strsplit(range_exprs[r], '-', /extract, count=n_endpts)
    case 1 of
      n_endpts eq 0:
      n_endpts eq 1: begin
          dates = [dates, endpts[0]]
          count += 1L
        end
      n_endpts eq 2: begin
          start_date = ucomp_decompose_date(endpts[0])
          end_date = ucomp_decompose_date(endpts[1])

          start_jd = julday(start_date[1], start_date[2], start_date[0])
          end_jd = julday(end_date[1], end_date[2], end_date[0])

          if (start_jd gt end_jd) then begin
            message, string(range_exprs[r], $
                            format='(%"invalid date expression ''%s''")')
          endif

          new_jds = timegen(start=start_jd, final=end_jd, units='days')
          new_dates = string(new_jds, format='(C(CYI, CMOI2.2, CDI2.2))')
          new_dates = new_dates[0:-2]   ; remove last date

          dates = [dates, new_dates]
          count += n_elements(new_dates)
        end
      else: begin
        message, string(expr, format='(%"invalid date expression ''%s''")')
      end
    endcase

  endfor

  return, dates
end


; main-level example program

;expr = '20170101-20170201,20180101'
expr = '20170101-20170201,20180101,20180501-20180514'
days = ucomp_parse_dateexpr(expr, count=n_days)
print, expr, n_days, format='(%"%s -> %d days")'
print, days

end
