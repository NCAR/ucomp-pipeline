; main-level example program

date = '20210725'
basename = '20210725.230123.ucomp.1074.continuum_correction.7.fts'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', 'config'], $
                           root=mg_src_root())
run = ucomp_run(date, 'unit', config_filename, /no_log)

filename = filepath(basename, $
                    subdir=[date, 'level1'], $
                    root=run->config('processing/basedir'))

fits_open, filename, fcb
fits_read, fcb, data, header, exten_no=4
fits_close, fcb

for c = 0, 1 do begin
  im = total(data[*, *, *, c], 3)
  radii = ucomp_radial_derivative(im, 330.0, 40.0, points=points)

  mg_image, bytscl(im, -0.1, 310.0), /new, title=string(c, format='Camera %d')
  plots, points[0, *], points[1, *], /device, color='0000ff'x, thick=2.0, linestyle=2
endfor

obj_destroy, run

end
