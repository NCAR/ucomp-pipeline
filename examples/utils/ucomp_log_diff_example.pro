; main-level example program

date = '20181115'
dir = string(date, format='(%"/Data/UCoMP/raw/%s")')

filename1 = filepath(string(date, format='(%"%s.ucomp.machine.log")'), root=dir)
filename2 = filepath(string(date, format='(%"%s.ucomp.t1.log")'), root=dir)
;filename2 = filepath(string(date, format='(%"%s.ucomp.t2.log")'), root=dir)
;filename2 = filepath(string(date, format='(%"%s.ucomp.l0.tarlist")'), root=dir)

diff = ucomp_log_diff(filename1, filename2, only_file1=only_file1, only_file2=only_file2)

if (n_elements(only_file1) gt 0L) then begin
  print, file_basename(filename1), format='(%"Files only in %s:")'
  print, '  ' + transpose(only_file1)
endif

if (n_elements(only_file2) gt 0L) then begin
  print, file_basename(filename2), format='(%"Files only in %s:")'
  print, '  ' + transpose(only_file2)
endif

if (diff eq 0) then begin
  print, 'No difference'
endif

end
