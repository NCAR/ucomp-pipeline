; docformat = 'rst'

pro ucomp_plot_zr, dir
  compile_opt strictarr

  files = file_search(filepath('*.fts', root=dir), count=n_files)

  jds = !null
  razr = !null
  deczr = !null

  for f = 0L, n_files - 1L do begin
    print, f + 1L, n_files, file_basename(files[f]), $
           format='reading %03d/%03d: %s...'
    fits_open, files[f], fcb

    for e = 1L, fcb.nextend do begin
      fits_read, fcb, !null, header, exten_no=e
      jds = [jds, ucomp_dateobs2julday(ucomp_getpar(header, 'DATE-BEG'))]
      razr = [razr, ucomp_getpar(header, 'SGSRAZR')]
      deczr = [deczr, ucomp_getpar(header, 'SGSDECZR')]
    endfor

    fits_close, fcb
  endfor

  symsize = 0.25
  !null = label_date(date_format='%H:%I')
  date = file_basename(dir)

  window, xsize=1000, ysize=800, title='ZR', /free

  !p.multi = [0, 1, 2, 0]

  plot, jds, razr, $
        xstyle=1, xtickformat='label_date', $
        psym=4, symsize=symsize, $
        title=string(date, format='RAZR for %s')

  plot, jds, deczr, $
        xstyle=1, xtickformat='label_date', $
        psym=4, symsize=symsize, $
        title=string(date, format='DECZR for %s')

  !p.multi = 0
end


; main-level example program

dir = '/hao/dawn/Data/UCoMP/incoming/20240330'
ucomp_plot_zr, dir

end
