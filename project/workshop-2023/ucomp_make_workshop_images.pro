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


; new config file

config_basename = 'ucomp.workshop.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())


; apply dark

date = '20220926'

run = ucomp_run(date, 'workshop', config_filename)
l1_dir = filepath('', subdir=[date, 'level1'], root=run->config('processing/basedir'))

basename = '20220926.205705.ucomp.1074.apply_dark.3.fts'
filename = filepath(basename, $
                    subdir=['03-apply_dark'], $
                    root=l1_dir)

fits_open, filename, fcb
fits_read, fcb, data, header, exten_no=2
fits_close, fcb

print, 'writing applied dark images...'
write_png, 'apply_dark.png', bytscl(data[*, *, 0, 0]^0.7, 0.0, 2000.0^0.7)
write_png, 'apply_dark_bkg.png', bytscl(data[*, *, 0, 1]^0.7, 0.0, 2000.0^0.7)

obj_destroy, run


; apply gain

date = '20220926'

run = ucomp_run(date, 'workshop', config_filename)
l1_dir = filepath('', subdir=[date, 'level1'], root=run->config('processing/basedir'))

basename = '20220926.205705.ucomp.1074.apply_gain.3.fts'
filename = filepath(basename, $
                    subdir=['04-apply_gain'], $
                    root=l1_dir)

fits_open, filename, fcb
fits_read, fcb, data, header, exten_no=2
fits_close, fcb

print, 'writing applied gain images...'
write_png, 'apply_gain.png', bytscl(data[*, *, 0, 0]^0.7, 0.0, 100.0^0.7)
write_png, 'apply_gain_bkg.png', bytscl(data[*, *, 0, 1]^0.7, 0.0, 100.0^0.7)

obj_destroy, run


; demodulation

date = '20220926'

run = ucomp_run(date, 'workshop', config_filename)
l1_dir = filepath('', subdir=[date, 'level1'], root=run->config('processing/basedir'))

basename = '20220926.205705.ucomp.1074.camera_correction.3.fts'
filename = filepath(basename, $
                    subdir=['05-camera_correction'], $
                    root=l1_dir)

fits_open, filename, fcb
fits_read, fcb, undemod_data, header, exten_no=2
fits_close, fcb

basename = '20220926.205705.ucomp.1074.demodulation.3.fts'
filename = filepath(basename, $
                    subdir=['07-demodulation'], $
                    root=l1_dir)

fits_open, filename, fcb
fits_read, fcb, demod_data, header, exten_no=2
fits_close, fcb


undemod_image = bytarr(2 * 1280, 2 * 1024)
undemod_image[0, 1024] = bytscl(undemod_data[*, *, 0, 0]^0.7, 0.0, 130.0^0.7)
undemod_image[1280, 1024] = bytscl(undemod_data[*, *, 1, 0]^0.7, 0.0, 130.0^0.7)
undemod_image[0, 0] = bytscl(undemod_data[*, *, 2, 0]^0.7, 0.0, 130.0^0.7)
undemod_image[1280, 0] = bytscl(undemod_data[*, *, 3, 0]^0.7, 0.0, 130.0^0.7)

demod_image = bytarr(2 * 1280, 2 * 1024)
demod_image[0, 1024] = bytscl(demod_data[*, *, 0, 0]^0.7, 0.0, 130.0^0.7)
demod_image[1280, 1024] = bytscl(demod_data[*, *, 1, 0], -1.0, 1.0)
demod_image[0, 0] = bytscl(demod_data[*, *, 2, 0]^0.7, -1.0, 1.0)
demod_image[1280, 0] = bytscl(demod_data[*, *, 3, 0]^0.7, -1.0, 1.0)

print, 'writing demodulated images...'
write_png, 'undemodulated.png', undemod_image
write_png, 'demodulated.png', demod_image

obj_destroy, run


; continuum subtraction

date = '20220926'

run = ucomp_run(date, 'workshop', config_filename)
l1_dir = filepath('', subdir=[date, 'level1'], root=run->config('processing/basedir'))

basename = '20220926.205705.ucomp.1074.continuum_subtraction.3.fts'
filename = filepath(basename, $
                    subdir=['10-continuum_subtraction'], $
                    root=l1_dir)

fits_open, filename, fcb
fits_read, fcb, continuum_data, header, exten_no=2
fits_close, fcb


continuum_image = bytarr(2 * 1280, 2 * 1024)
continuum_image[0, 1024] = bytscl(continuum_data[*, *, 0, 0]^0.7, 0.0, 40.0^0.7)
continuum_image[1280, 1024] = bytscl(continuum_data[*, *, 1, 0], -1.0, 1.0)
continuum_image[0, 0] = bytscl(continuum_data[*, *, 2, 0], -1.0, 1.0)
continuum_image[1280, 0] = bytscl(continuum_data[*, *, 3, 0], -1.0, 1.0)

print, 'writing continuum subtracted images...'
write_png, 'continuum.png', continuum_image

obj_destroy, run


; debanding

date = '20220926'

run = ucomp_run(date, 'workshop', config_filename)
l1_dir = filepath('', subdir=[date, 'level1'], root=run->config('processing/basedir'))

basename = '20220926.205705.ucomp.1074.debanding.3.fts'
filename = filepath(basename, $
                    subdir=['11-debanding'], $
                    root=l1_dir)

fits_open, filename, fcb
fits_read, fcb, debanding_data, header, exten_no=2
fits_close, fcb


debanding_image = bytarr(2 * 1280, 2 * 1024)
debanding_image[0, 1024] = bytscl(debanding_data[*, *, 0, 0]^0.7, 0.0, 40.0^0.7)
debanding_image[1280, 1024] = bytscl(debanding_data[*, *, 1, 0], -1.0, 1.0)
debanding_image[0, 0] = bytscl(debanding_data[*, *, 2, 0], -1.0, 1.0)
debanding_image[1280, 0] = bytscl(debanding_data[*, *, 3, 0], -1.0, 1.0)

print, 'writing debanded images...'
write_png, 'debanded.png', debanding_image

obj_destroy, run


; apply alignment

date = '20220926'

run = ucomp_run(date, 'workshop', config_filename)
l1_dir = filepath('', subdir=[date, 'level1'], root=run->config('processing/basedir'))

basename = '20220926.205705.ucomp.1074.apply_alignment.3.fts'
filename = filepath(basename, $
                    subdir=['12-apply_alignment'], $
                    root=l1_dir)

fits_open, filename, fcb
fits_read, fcb, aligned_data, header, exten_no=2
fits_close, fcb


aligned_image = bytarr(2 * 1280, 2 * 1024)
aligned_image[0, 1024] = bytscl(aligned_data[*, *, 0, 0]^0.7, 0.0, 40.0^0.7)
aligned_image[1280, 1024] = bytscl(aligned_data[*, *, 1, 0], -1.0, 1.0)
aligned_image[0, 0] = bytscl(aligned_data[*, *, 2, 0], -1.0, 1.0)
aligned_image[1280, 0] = bytscl(aligned_data[*, *, 3, 0], -1.0, 1.0)

print, 'writing aligned images...'
write_png, 'aligned.png', aligned_image

obj_destroy, run


; combine cameras

date = '20220926'

run = ucomp_run(date, 'workshop', config_filename)
l1_dir = filepath('', subdir=[date, 'level1'], root=run->config('processing/basedir'))

basename = '20220926.205705.ucomp.1074.combine_cameras.3.fts'
filename = filepath(basename, $
                    subdir=['13-combine_cameras'], $
                    root=l1_dir)

fits_open, filename, fcb
fits_read, fcb, combined_data, header, exten_no=2
fits_close, fcb


combined_image = bytarr(2 * 1280, 2 * 1024)
combined_image[0, 1024] = bytscl(combined_data[*, *, 0]^0.7, 0.0, 40.0^0.7)
combined_image[1280, 1024] = bytscl(combined_data[*, *, 1], -1.0, 1.0)
combined_image[0, 0] = bytscl(combined_data[*, *, 2], -1.0, 1.0)
combined_image[1280, 0] = bytscl(combined_data[*, *, 3], -1.0, 1.0)

print, 'writing combined images...'
write_png, 'combined.png', combined_image

obj_destroy, run


; polarimetric correction

date = '20220926'

run = ucomp_run(date, 'workshop', config_filename)
l1_dir = filepath('', subdir=[date, 'level1'], root=run->config('processing/basedir'))

basename = '20220926.205705.ucomp.1074.polarimetric_correction.3.fts'
filename = filepath(basename, $
                    subdir=['15-polarimetric_correction'], $
                    root=l1_dir)

fits_open, filename, fcb
fits_read, fcb, polarimetric_data, header, exten_no=2
fits_close, fcb


polarimetric_image = bytarr(2 * 1280, 2 * 1024)
polarimetric_image[0, 1024] = bytscl(polarimetric_data[*, *, 0]^0.7, 0.0, 40.0^0.7)
polarimetric_image[1280, 1024] = bytscl(polarimetric_data[*, *, 1], -1.0, 1.0)
polarimetric_image[0, 0] = bytscl(polarimetric_data[*, *, 2], -1.0, 1.0)
polarimetric_image[1280, 0] = bytscl(polarimetric_data[*, *, 3], -1.0, 1.0)

print, 'writing polarimetric images...'
write_png, 'polarimetric.png', polarimetric_image

obj_destroy, run

end
