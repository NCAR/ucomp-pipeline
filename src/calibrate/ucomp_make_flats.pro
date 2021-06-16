; docformat = 'rst'

;+
; Create averaged flats for each file and put these into extensions of the
; master flat file. Primary header of the master flat file comes from the
; primary header of the first raw flat file of the day, while the extension
; header corresponding to each raw flat file comes from the header of the first
; extension of each raw flat file.
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

  flat_times          = list()
  flat_exposures      = list()
  flat_wavelengths    = list()
  flat_gain_modes     = list()
  flat_onbands        = list()

  flat_raw_files      = list()

  flat_data           = list()
  flat_headers        = list()
  flat_extnames       = list()

  datetime = strmid(file_basename((flat_files[0]).raw_filename), 0, 15)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)
  n_pol_states = 4L
  n_cameras = 2L

  ; the keywords that need to be moved from the primary header in the raw files
  ; to the extension headers in the master flat file
  demoted_keywords = ['T_C0ARR', 'T_C0PCB', 'T_C1ARR', 'T_C1PCB', $
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
    flat_time = total(hst_dtime * [1.0, 1.0 / 60.0, 1.0 / 60.0 / 60.0])

    ucomp_read_raw_data, flat_file.raw_filename, $
                         primary_data=primary_data, $
                         primary_header=primary_header, $
                         ext_data=ext_data, $
                         ext_headers=ext_headers, $
                         n_extensions=n_extensions, $
                         repair_routine=run->epoch('raw_data_repair_routine', datetime=datetime)

    ; use the primary header of the first flat file as the template for the
    ; primary header of the master flat file
    if (f eq 0L) then first_primary_header = primary_header

    ucomp_average_flatfile, primary_header, ext_data, ext_headers, $
                            n_extensions=n_averaged_extensions, $
                            exptime=averaged_exptime, $
                            gain_mode=averaged_gain_mode, $
                            onband=averaged_onband, $
                            wavelength=averaged_wavelength

    ; move demoted_keywords from primary header to extension headers
    for k = 0L, n_elements(demoted_keywords) - 1L do begin
      value = ucomp_getpar(primary_header, demoted_keywords[k], comment=comment)
      type = size(value, /type)
      after = k eq 0L ? 'T_RACK' : demoted_keywords[k]
      for e = 0L, n_averaged_extensions - 1L do begin
        ext_header = ext_headers[e]
        ucomp_addpar, ext_header, $
                      'RAWFILE', $
                      file_basename(flat_file.raw_filename)
        ucomp_addpar, ext_header, $
                      demoted_keywords[k], $
                      value, $
                      comment=comment, $
                      format=type eq 4 || type eq 5 ? '(F0.3)' : !null, $
                      after=after
        ext_headers[e] = ext_header
      endfor
    endfor

    flat_headers->add, ext_headers, /extract

    flat_raw_files->add, strarr(n_averaged_extensions) + flat_basename, /extract
    flat_times->add, fltarr(n_averaged_extensions) + flat_time, /extract

    flat_exposures->add, averaged_exptime, /extract
    flat_wavelengths->add, averaged_wavelength, /extract
    flat_gain_modes->add, averaged_gain_mode, /extract
    flat_onbands->add, averaged_onband, /extract

    for e = 0L, n_averaged_extensions - 1L do begin
      flat_extnames->add, string(averaged_wavelength[e], $
                                 averaged_onband[e] ? 'tcam' : 'rcam', $
                                 format='(%"%0.2f nm [%s]")')
      flat_data->add, reform(ext_data[*, *, *, *, e])
    endfor
  endfor

  ; remove keywords that were moved from the primary header to the extension
  ; headers from the primary header
  for k = 0L, n_elements(demoted_keywords) - 1L do begin
    sxdelpar, first_primary_header, demoted_keywords[k]
  endfor

  ; add a few more keywords to master flat file primary header
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

  flat_times_array       = flat_times->toArray()
  flat_exposures_array   = flat_exposures->toArray()
  flat_wavelengths_array = flat_wavelengths->toArray()
  flat_gain_modes_array  = flat_gain_modes->toArray()
  flat_onbands_array     = flat_onbands->toArray()
  flat_raw_files_array   = flat_raw_files->toArray()
  obj_destroy, [flat_times, $
                flat_exposures, $
                flat_wavelengths, $
                flat_gain_modes, $
                flat_onbands, $
                flat_raw_files]

  ; write master flat FITS file in the process_dir/level1

  output_basename = string(run.date, wave_region, format='(%"%s.ucomp.flat.%s.fts")')
  output_filename = filepath(output_basename, root=l1_dir)

  fits_open, output_filename, output_fcb, /write
  fits_write, output_fcb, 0, first_primary_header
  flat_raw_extensions = strarr(n_elements(flat_headers))
  for f = 0L, n_elements(flat_headers) - 1L do begin
    flat_raw_extensions[f] = ucomp_getpar(flat_headers[f], 'RAWEXTS')
    fits_write, output_fcb, $
                flat_data[f], $
                flat_headers[f], $
                extname=flat_extnames[f]
  endfor

  mkhdr, times_header, flat_times_array, /extend, /image
  fits_write, output_fcb, flat_times_array, times_header, extname='Times'

  mkhdr, exposures_header, flat_exposures_array, /extend, /image
  fits_write, output_fcb, flat_exposures_array, exposures_header, extname='Exposures'

  mkhdr, wavelengths_header, flat_wavelengths_array, /extend, /image
  fits_write, output_fcb, flat_wavelengths_array, wavelengths_header, extname='Wavelengths'

  mkhdr, gain_modes_header, flat_gain_modes_array, /extend, /image
  fits_write, output_fcb, flat_gain_modes_array, gain_modes_header, extname='Gain modes'

  mkhdr, onbands_header, flat_onbands_array, /extend, /image
  fits_write, output_fcb, flat_onbands_array, onbands_header, extname='Onbands'

  fits_close, output_fcb

  flat_data_array = flat_data->toArray(/transpose)

  ; cache flats
  cal = run.calibration
  cal->cache_flats, flats=flat_data_array, $
                    times=flat_times_array, $
                    exptimes=flat_exposures_array, $
                    wavelengths=flat_wavelengths_array, $
                    gain_modes=flat_gain_modes_array, $
                    onbands=flat_onbands_array, $
                    raw_files=flat_raw_files_array, $
                    extensions=flat_raw_extensions

  done:
  if (obj_valid(flat_headers)) then obj_destroy, flat_headers
  if (obj_valid(flat_data)) then obj_destroy, flat_data
  if (obj_valid(flat_extnames)) then obj_destroy, flat_extnames
end
