; main-level example program

f = 'ucomp_hst2ut.pro'
print, ucomp_julday2dateobs(systime(elapsed=file_modtime(f), /julian))

end
