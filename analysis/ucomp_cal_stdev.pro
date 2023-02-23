; docformat = 'rst'

pro ucomp_cal_stdev, start_date, end_date, config_filename
  compile_opt strictarr

  n_darks = 0L
  sum     = fltarr(1280, 1024, 2)
  sum2    = fltarr(1280, 1024, 2)

  date = start_date
  while date ne end_date do begin
    run = ucomp_run(date, 'analysis', config_filename)
    mg_log, 'checking %s...', date, name='analysis', /info

    dark_basename = string(date, format='%s.ucomp.dark.fts')
    dark_filename = filepath(dark_basename, $
                             subdir=[date, 'level1'], $
                             root=run->config('processing/basedir'))

    if (file_test(dark_filename)) then begin
      mg_log, 'checking %s...', dark_filename, name='analysis', /info
      fits_open, dark_filename, fcb
      for e = 1L, fcb.nextend - 3L do begin
        fits_read, fcb, dark, dark_header, exten_no=e

        n_darks += 1L
        sum     += dark
        sum2    += dark^2
      endfor
      fits_close, fcb
    endif

    obj_destroy, run

    date = ucomp_increment_date(date)
  endwhile

  s = sqrt((sum2 - 2.0 * sum^2 / n_darks + sum^2 / n_darks) / n_darks)

  rcam = s[*, *, 0]
  tcam = s[*, *, 1]

  mg_image, bytscl(rcam^0.5, 0.0, 10.0), /new, title='RCAM standard deviation'
  mg_image, bytscl(tcam^0.5, 0.0, 10.0), /new, title='TCAM standard deviation'
end


; main-level example program

config_basename = 'ucomp.production.cfg'
config_basedir = '/home/mgalloy/projects/ucomp-config'
config_filename = filepath(config_basename, root=config_basedir)

ucomp_cal_stdev, '20220801', '20221201', config_filename

end
