; Example of restoring calibration files (master dark and flat files) and using
; them -- for example to dark correct a flat.

date = '20240409'
wave_region = '1074'
config_basename = 'ucomp.latest.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

run = ucomp_run(date, 'test', config_filename)

l1_dir = filepath('', $
                  subdir=[date, 'level1'], $
                  root=run->config('processing/basedir'))

master_dark_basename = string(date, format='%s.ucomp.dark.fts')
master_dark_filename = filepath(master_dark_basename, root=l1_dir)

master_flat_basename = string(date, wave_region, format='%s.ucomp.%s.flat.fts')
master_flat_filename = filepath(master_flat_basename, root=l1_dir)

cal = ucomp_calibration(run=run)
cal->cache_darks, master_dark_filename
cal->cache_flats, master_flat_filename

; choose the flat extension that you want to dark correct
e = 1L

fits_open, master_flat_filename, fcb
fits_read, fcb, flat, flat_header, exten_no=e
fits_read, fcb, flat_times, exten_no=fcb.nextend - 4L
fits_read, fcb, flat_exposures, exten_no=fcb.nextend - 3L
fits_read, fcb, flat_gain_indices, exten_no=fcb.nextend - 1L
fits_close, fcb

gain_modes = ['low', 'high']
flat_dark = cal->get_dark(flat_times[e - 1L], $
                          flat_exposures[e - 1L], $
                          gain_modes[flat_gain_indices[e - 1L]], $
                          found=found, $
                          coefficients=coefficients, $
                          master_extensions=master_extensions)


window, xsize=1280, ysize=1024, title='flat: camera 0', /free
tv, bytscl(flat, 200.0, 400.0)
print, median(flat)
window, xsize=1280, ysize=1024, title='dark corrected flat: camera 0', /free
tv, bytscl(flat - flat_dark, 200.0, 400.0)
print, median(flat - flat_dark)

obj_destroy, [cal, run]

end
