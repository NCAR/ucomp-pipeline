; docformat = 'rst'

;+
; Create an averaged flat for each file and put this into an extension of the
; master flat file. Primary header of of the master flat file comes from the
; primary header of the first raw flat file of the day, while the extension
; header corresponding to each raw flat file comes from the header of the first
; extension of each raw flatfile.
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_make_flats, wave_region, run=run
  compile_opt strictarr

  mg_log, 'making flats for %s nm...', wave_region, name=run.logger_name, /info

  ; query run object for all the flat files for a given wave region
  flat_files = run->get_files(data_type='flat', wave_region=wave_region, $
                              count=n_flat_files)

  if (n_flat_files eq 0L) then begin
    mg_log, 'no flats for %s nm, not making master flat file', wave_region, $
            name=run.logger_name, /warn
    goto, done
  endif

  l1_dir = filepath('level1', $
                    subdir=run.date, $
                    root=run->config('processing/basedir'))
  if (~file_test(l1_dir, /directory)) then file_mkdir, l1_dir

  flat_times = fltarr(n_flat_files)
  flat_exposures = fltarr(n_flat_files)

  datetime = strmid(file_basename((flat_files[0]).raw_filename), 0, 15)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)
  n_pol_states = 4L
  n_cameras = 2L

  averaged_flat_images = fltarr(nx, ny, n_pol_states, n_cameras, n_flat_files)
  flat_headers = list()

  for f = 0L, n_flat_files - 1L do begin
    flat_file = flat_files[f]
    flat_basename = file_basename(flat_file.raw_filename)
    mg_log, '%d/%d: processing %s', $
            f + 1, n_flat_files, flat_basename, $
            name=run.logger_name, /debug

    ucomp_ut2hst, strmid(flat_basename, 0, 8), strmid(flat_basename, 9, 6), $
                  hst_date=hst_date, hst_time=hst_time

    hst_dtime = float(ucomp_decompose_time(hst_time))
    flat_times[f] = total(hst_dtime * [1.0, 1.0 / 60.0, 1.0 / 60.0 / 60.0])

    fits_open, flat_file.raw_filename, flat_file_fcb

    ; use the primary header of the first flat file as the template for the
    ; primary header of the master flat file
    if (f eq 0L) then begin
      fits_read, flat_file_fcb, empty, primary_header, exten_no=0, /header_only
    endif

    for e = 1L, flat_file_fcb.nextend do begin
      fits_read, flat_file_fcb, flat_image, flat_header, exten_no=e
      if (e eq 1L) then begin
        flat_exposures[f] = ucomp_getpar(flat_header, 'EXPTIME', /float)
        flat_headers->add, flat_header
      endif

      ; TODO: how does this work, should it be kept per pol state and camera or
      ; averaged together?
      averaged_flat_images[*, *, *, *, f] += flat_image
    endfor
    averaged_flat_images[*, *, *, *, f] /= flat_file_fcb.nextend
    fits_close, flat_file_fcb
  endfor

  ; TODO: fix primary header

  ; write master flat FITS file in the process_basedir/level

  output_basename = string(run.date, wave_region, format='(%"%s.ucomp.flat.%s.fts")')
  output_filename = filepath(output_basename, root=l1_dir)

  fits_open, output_filename, output_fcb, /write
  fits_write, output_fcb, 0, primary_header
  for f = 0L, n_flat_files - 1L do begin
    flat_header = flat_headers[f]
    ; TODO: fix extension header
    fits_write, output_fcb, $
                averaged_flat_images[*, *, *, *, f], $
                flat_header, $
                extname=strmid(file_basename(flat_files[f].raw_filename), 9, 6)
  endfor

  fits_write, output_fcb, flat_times, flat_header, extname='Times'
  fits_write, output_fcb, flat_exposures, flat_header, extname='Exposures'

  fits_close, output_fcb

  done:
  if (obj_valid(flat_headers)) then obj_destroy, flat_headers
end
