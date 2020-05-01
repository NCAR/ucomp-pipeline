; docformat = 'rst'

;+
; Create an averaged dark for each file and put this into a file.
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_make_darks, run=run
  compile_opt strictarr

  mg_log, 'making darks...', name=run.logger_name, /info

  ; query run object for all the dark files
  dark_files = run->get_files(data_type='dark', count=n_dark_files)

  if (n_dark_files eq 0L) then goto, done

  l1_dir = filepath('level1', $
                    subdir=run.date, $
                    root=run->config('processing/basedir'))
  if (~file_test(l1_dir, /directory)) then file_mkdir, l1_dir

  dark_times = fltarr(n_dark_files)
  dark_exposures = fltarr(n_dark_files)

  datetime = strmid(file_basename((dark_files[0]).raw_filename), 0, 15)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)
  n_pol_states = 4L
  n_cameras = 2L
  averaged_dark_images = fltarr(nx, ny, n_pol_states, n_cameras, n_dark_files)

  for d = 0L, n_dark_files - 1L do begin
    dark_file = dark_files[d]
    dark_basename = file_basename(dark_file.raw_filename)
    mg_log, '%d/%d: processing %s', $
            d + 1, n_dark_files, dark_basename, $
            name=run.logger_name, /debug

    ucomp_ut2hst, strmid(dark_basename, 0, 8), strmid(dark_basename, 9, 6), $
                  hst_date=hst_date, hst_time=hst_time

    hst_dtime = float(ucomp_decompose_time(hst_time))
    dark_times[d] = total(hst_dtime * [1.0, 1.0 / 60.0, 1.0 / 60.0 / 60.0])

    fits_open, dark_file.raw_filename, dark_file_fcb
    for e = 1L, dark_file_fcb.nextend do begin
      fits_read, dark_file_fcb, dark_image, dark_header, exten_no=e
      if (e eq 1L) then dark_exposures[d] = ucomp_getpar(dark_header, 'EXPTIME', /float)

      ; TODO: how does this work, should it be kept per pol state and camera or
      ; averaged together?
      averaged_dark_images[*, *, *, *, d] += dark_image
    endfor
    averaged_dark_images[*, *, *, *, d] /= dark_file_fcb.nextend
    fits_close, dark_file_fcb
  endfor

  ; write dark FITS file in the process_basedir/level

  output_basename = string(run.date, format='(%"%s.ucomp.dark.fts")')
  output_filename = filepath(output_basename, root=l1_dir)

  fits_open, output_filename, output_fcb, /write
  fits_write, output_fcb, 0, primary_header
  for d = 0L, n_dark_files - 1L do begin
    fits_write, output_fcb, $
                averaged_dark_images[*, *, *, *, d], $
                dark_header, $   ; TODO: create real headers
                extname=strmid(file_basename(dark_files[d].raw_filename), 9, 6)
  endfor

  ; TODO: fill in dark_header below with real headers
  fits_write, output_fcb, dark_times, dark_header, extname='Times'
  fits_write, output_fcb, dark_exposures, dark_header, extname='Exposures'

  fits_close, output_fcb

  done:
end
