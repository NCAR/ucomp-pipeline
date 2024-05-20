; main-level example program

mode = 'test'
logger_name = 'ucomp/' + mode
cfile = 'ucomp.production.cfg'
config_filename = filepath(cfile, subdir=['..', '..', 'config'], root=mg_src_root())

dates = ['20220417', '20220418', '20220423']
;dates = ['20220423']
for d = 0L, n_elements(dates) - 1L do begin
  ucomp_verify, dates[d], config_filename, mode=mode

  if (d lt n_elements(dates) - 1L) then begin
    mg_log, name=logger_name, logger=logger
    logger->setProperty, format='%(time)s %(levelshortname)s: %(message)s'
    mg_log, '-----------------------------------', name=logger_name, /info
  endif
endfor

end
