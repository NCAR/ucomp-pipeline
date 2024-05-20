; main-level example

basename = '20200826.013737.45.ucomp.l0.fts'
root = '/hao/twilight/Data/UCoMP/raw.test/20200825'
filename = filepath(basename, root=root)

fits_open, filename, fcb
fits_read, fcb, data, header, exten_no=1L
fits_close, fcb

data = reform(data[*, *, 0, 0])

ucomp_create_gif, data, 'test.gif', /show_range, title=file_basename(filename)

end
