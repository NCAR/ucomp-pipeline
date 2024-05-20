; main-level example program

;expr = '20170101-20170201,20180101'
expr = '20170101-20170201,20180101,20180501-20180514'
days = ucomp_parse_dateexpr(expr, count=n_days)
print, expr, n_days, format='(%"%s -> %d days")'
print, days

end
