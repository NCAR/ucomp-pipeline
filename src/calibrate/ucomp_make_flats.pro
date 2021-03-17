; docformat = 'rst'

;+
; Create an averaged flat for each file and put this into an extension of the
; master flat file. Primary header of of the master flat file comes from the
; primary header of the first raw flat file of the day, while the extension
; header corresponding to each raw flat file comes from the header of the first
; extension of each raw flatfile.
;
; :Params:
;   wave_region : in, required, type=string
;     wave region to find flats for
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
  ucomp_mkdir, l1_dir, logger_name=run.logger_name

  flat_times = fltarr(n_flat_files)
  flat_exposures = fltarr(n_flat_files)
  flat_wavelengths = fltarr(n_flat_files)
  flat_gain_modes = intarr(n_flat_files)
  flat_extensions = lonarr(n_flat_files)
  flat_raw_files = strarr(n_flat_files)

  datetime = strmid(file_basename((flat_files[0]).raw_filename), 0, 15)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)
  n_pol_states = 4L
  n_cameras = 2L

  averaged_flat_images = fltarr(nx, ny, n_pol_states, n_cameras, n_flat_files)
  flat_headers = list()

  ; the keywords that need to be moved from the primary header in the raw files
  ; to the extensions in the master flat file
  move_keywords = ['T_C0ARR', 'T_C0PCB', 'T_C1ARR', 'T_C1PCB', $
                   'GAIN', 'OCCLTR-X', 'OCCLTR-Y', 'O1FOCUSE']

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
    fits_read, flat_file_fcb, empty, primary_header, exten_no=0, /header_only
    if (f eq 0L) then first_primary_header = primary_header

    move_keywords_hash = hash()
    for k = 0L, n_elements(move_keywords) - 1L do begin
      move_keywords_hash[move_keywords[k]] = ucomp_getpar(primary_header, $
                                                          move_keywords[k], $
                                                          comment=comment)
      move_keywords_hash[move_keywords[k] + '_COMMENT'] = comment
    endfor

    flat_gain_modes[f] = strtrim(move_keywords_hash['GAIN'], 2) eq 'high'
    flat_extensions[f] = f + 1L
    flat_raw_files[f] = flat_basename

    for e = 1L, flat_file_fcb.nextend do begin
      fits_read, flat_file_fcb, flat_image, flat_header, exten_no=e
      if (e eq 1L) then begin
        flat_exposures[f] = ucomp_getpar(flat_header, 'EXPTIME', /float)
        flat_wavelengths[f] = ucomp_getpar(flat_header, 'WAVELNG', /float)

        ucomp_addpar, flat_header, 'RAWFILE', flat_basename, $
                      comment='corresponding raw flat filename', $
                      before='DATATYPE'

        for k = 0L, n_elements(move_keywords) - 1L do begin
          after = k eq 0L ? 'T_RACK' : move_keywords[k - 1L]
          type = size(move_keywords_hash[move_keywords[k]], /type)
          ucomp_addpar, flat_header, move_keywords[k], $
                        move_keywords_hash[move_keywords[k]], $
                        comment=move_keywords_hash[move_keywords[k] + '_COMMENT'], $
                        format=type eq 4 || type eq 5 ? '(F0.3)' : !null, $
                        after=after
        endfor
        obj_destroy, move_keywords_hash
        flat_headers->add, flat_header
      endif

      ; TODO: how does this work, should it be kept per pol state and camera or
      ; averaged together?
      averaged_flat_images[*, *, *, *, f] += flat_image
    endfor
    averaged_flat_images[*, *, *, *, f] /= flat_file_fcb.nextend
    fits_close, flat_file_fcb
  endfor

  ; fix primary header

  for k = 0L, n_elements(move_keywords) - 1L do begin
    sxdelpar, first_primary_header, move_keywords[k]
  endfor

  ; get current date & time
  current_time = systime(/utc)
  date_dp = string(bin_date(current_time), $
                   format='(%"%04d-%02d-%02dT%02d:%02d:%02d")')
  fxaddpar, first_primary_header, 'DATE_DP', date_dp, ' L1 processing date (UTC)', $
            after='OBS_PLVE'
  version = ucomp_version(revision=revision, branch=branch, date=code_date)
  fxaddpar, first_primary_header, 'DPSWID',  $
            string(version, revision, $
                   format='(%"%s [%s]")'), $
            string(code_date, $
                   format='(%" L1 data processing software (%s)")'), $
            after='DATE_DP'

  ; write master flat FITS file in the process_basedir/level

  output_basename = string(run.date, wave_region, format='(%"%s.ucomp.flat.%s.fts")')
  output_filename = filepath(output_basename, root=l1_dir)

  fits_open, output_filename, output_fcb, /write
  fits_write, output_fcb, 0, first_primary_header
  for f = 0L, n_flat_files - 1L do begin
    flat_header = flat_headers[f]
    ; TODO: fix extension header
    fits_write, output_fcb, $
                averaged_flat_images[*, *, *, *, f], $
                flat_header, $
                extname=strmid(file_basename(flat_files[f].raw_filename), 9, 6)
  endfor

  mkhdr, times_header, flat_times, /extend, /image
  fits_write, output_fcb, flat_times, times_header, extname='Times'

  mkhdr, exposures_header, flat_exposures, /extend, /image
  fits_write, output_fcb, flat_exposures, exposures_header, extname='Exposures'

  mkhdr, wavelengths_header, flat_wavelengths, /extend, /image
  fits_write, output_fcb, flat_wavelengths, wavelengths_header, extname='Wavelengths'

  mkhdr, gain_modes_header, flat_gain_modes, /extend, /image
  fits_write, output_fcb, flat_gain_modes, gain_modes_header, extname='Gain modes'

  fits_close, output_fcb

  ; cache flats
  cal = run.calibration
  cal->cache_flats, flats=averaged_flat_images, $
                    times=flat_times, $
                    exptimes=flat_exposures, $
                    wavelengths=flat_wavelengths, $
                    gain_modes=flat_gain_modes, $
                    extensions=flat_extensions, $
                    raw_files=flat_raw_files

  done:
  if (obj_valid(flat_headers)) then obj_destroy, flat_headers
end
