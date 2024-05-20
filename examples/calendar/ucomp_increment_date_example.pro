; main-level example program

dates = ['20111231', '20130605', '20200228']
fmt = '(%"%s -> %s -> %s")'
for d = 0L, n_elements(dates) - 1L do begin
  print, dates[d], $
         ucomp_increment_date(dates[d]), $
         ucomp_increment_date(ucomp_increment_date(dates[d])), $
         format=fmt
endfor

end
