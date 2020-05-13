; docformat = 'rst'

;+
; Create an averaged dark for each file and put this into an extension of the
; master dark file. Primary header of of the master dark file comes from the
; primary header of the first raw dark file of the day, while the extension
; header corresponding to each raw dark file comes from the header of the first
; extension of each raw dark file.
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
  if (n_dark_files eq 0L) then begin
    mg_log, 'no darks, not making master dark file', $
            name=run.logger_name, /warn
    goto, done
  endif

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
  dark_headers = list()
  dark_info = list()

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

    ; use the primary header of the first dark file as the template for the
    ; primary header of the master dark file
    fits_read, dark_file_fcb, empty, primary_header, exten_no=0, /header_only
    if (d eq 0L) then first_primary_header = primary_header

    t_c0arr = sxpar(primary_header, 'T_C0ARR', comment=t_c0arr_comment)
    t_c0pcb = sxpar(primary_header, 'T_C0PCB', comment=t_c0pcb_comment)
    t_c1arr = sxpar(primary_header, 'T_C1ARR', comment=t_c1arr_comment)
    t_c1pcb = sxpar(primary_header, 'T_C1PCB', comment=t_c1pcb_comment)
    dark_info->add, {times: ucomp_dateobs2hours(sxpar(primary_header, 'DATE-OBS')), $
                     t_c0arr: t_c0arr, $
                     t_c0pcb: t_c0pcb, $
                     t_c1arr: t_c1arr, $
                     t_c1pcb: t_c1pcb}

    for e = 1L, dark_file_fcb.nextend do begin
      fits_read, dark_file_fcb, dark_image, dark_header, exten_no=e
      if (e eq 1L) then begin
        dark_exposures[d] = ucomp_getpar(dark_header, 'EXPTIME', /float)

        sxaddpar, dark_header, 'T_C0ARR', t_c0arr_comment, after='T_RACK'
        sxaddpar, dark_header, 'T_C0PCB', t_c0pcb_comment, after='T_C0ARR'
        sxaddpar, dark_header, 'T_C1ARR', t_c1arr_comment, after='T_C0PCB'
        sxaddpar, dark_header, 'T_C1PCB', t_c1pcb_comment, after='T_C1ARR'
        dark_headers->add, dark_header
      endif

      ; TODO: how does this work, should it be kept per pol state and camera or
      ; averaged together?
      averaged_dark_images[*, *, *, *, d] += dark_image
    endfor
    averaged_dark_images[*, *, *, *, d] /= dark_file_fcb.nextend
    fits_close, dark_file_fcb
  endfor

  ; TODO: fix primary header

  ; write master dark FITS file in the process_basedir/level

  output_basename = string(run.date, format='(%"%s.ucomp.dark.fts")')
  output_filename = filepath(output_basename, root=l1_dir)

  fits_open, output_filename, output_fcb, /write
  fits_write, output_fcb, 0, first_primary_header
  for d = 0L, n_dark_files - 1L do begin
    dark_header = dark_headers[d]
    ; TODO: fix extension header
    fits_write, output_fcb, $
                averaged_dark_images[*, *, *, *, d], $
                dark_header, $
                extname=strmid(file_basename(dark_files[d].raw_filename), 9, 6)
  endfor

  fits_write, output_fcb, dark_times, dark_header, extname='Times'
  fits_write, output_fcb, dark_exposures, dark_header, extname='Exposures'

  fits_close, output_fcb

  ; cache darks
  run->cache_darks, darks=averaged_dark_images, $
                    times=dark_times, $
                    exptimes=dark_exposures

  
  ucomp_dark_plots, dark_info->toArray(), run=run

  done:
  if (obj_valid(dark_headers)) then obj_destroy, dark_headers
  if (obj_valid(dark_info)) then obj_destroy, dark_info
end
