config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())


; raw data images

date = '20220926'

run = ucomp_run(date, 'workshop', config_filename)
raw_dir = filepath(date, root=run->config('raw/basedir'))

basename = '20220926.205705.00.ucomp.1074.l0.fts'
filename = filepath(basename, root=raw_dir)

fits_open, filename, fcb
fits_read, fcb, data, header, exten_no=3
fits_close, fcb

im0 = bytarr(2 * 1280, 2 * 1024)
im1 = bytarr(2 * 1280, 2 * 1024)

for p = 0, 3 do begin
  x = 1280 * (p mod 2)
  y = 1024 * (1 - p / 2)
  im0[x, y] = bytscl(data[*, *, p, 0], 0.0, 32767.0)
  im1[x, y] = bytscl(data[*, *, p, 1], 0.0, 32767.0)
endfor

print, 'writing raw images...'
write_png, 'raw_rcam.png', im0
write_png, 'raw_tcam.png', im1

obj_destroy, run


; make bad frame images

date = '20220830'

run = ucomp_run(date, 'workshop', config_filename)
raw_dir = filepath(date, root=run->config('raw/basedir'))

badframe_extension = 6
badframe_polstate = 0
badframe_camera = 1

badframe_filename = filepath('20220830.202216.42.ucomp.1074.l0.fts', root=raw_dir)
goodframe_filename = filepath('20220830.202250.02.ucomp.1074.l0.fts', root=raw_dir)

fits_open, badframe_filename, fcb
fits_read, fcb, badframe_data, header, exten_no=badframe_extension
fits_close, fcb

badframe = reform(badframe_data[*, *, badframe_polstate, badframe_camera])

fits_open, goodframe_filename, fcb
fits_read, fcb, goodframe_data, header, exten_no=badframe_extension
fits_close, fcb

goodframe = reform(goodframe_data[*, *, badframe_polstate, badframe_camera])

print, 'writing bad frame images...'
write_png, 'badframe.png', bytscl(badframe, 0.0, 32767.0)
write_png, 'goodframe.png', bytscl(goodframe, 0.0, 32767.0)

obj_destroy, run

end
