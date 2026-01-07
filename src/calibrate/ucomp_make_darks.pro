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

  ok_dark_files = bytarr(n_dark_files)
  for f = 0L, n_dark_files - 1L do ok_dark_files[f] = dark_files[f].ok

  good_dark_files_indices = where(ok_dark_files, n_good_dark_files)
  if (n_good_dark_files eq 0L) then begin
    mg_log, 'no good darks, not making master dark file', $
            name=run.logger_name, /warn
    goto, done
  endif else begin
    dark_files = dark_files[good_dark_files_indices]
    n_dark_files = n_good_dark_files
  endelse

  l1_dir = filepath('level1', $
                    subdir=run.date, $
                    root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dir, logger_name=run.logger_name

  nx = strmid(file_basename((dark_files[0]).raw_filename), 0, 15)
  nx = run->epoch('nx', datetime=datetime)
  ny = run->epoch('ny', datetime=datetime)
  n_pol_states = 4L
  n_cameras = 2L

  dark_times      = list()
  dark_exposures  = list()
  dark_gain_modes = list()
  dark_nucs       = list()
  dark_raw_files  = list()

  dark_data       = list()
  dark_headers    = list()
  dark_extnames   = list()
  dark_info       = list()

  n_tcam = 0L
  tcam_means = fltarr(n_pol_states)
  n_rcam = 0L
  rcam_means = fltarr(n_pol_states)

  ; the keywords that need to be moved from the primary header in the raw files
  ; to the extensions in the master dark file
  demoted_keywords = ['TU_C0ARR', 'TU_C0PCB', 'TU_C1ARR', 'TU_C1PCB', $
                      'GAIN', 'FILTER', 'OCCLTR-X', 'OCCLTR-Y', 'O1FOCUSE']

  for d = 0L, n_dark_files - 1L do begin
    dark_file = dark_files[d]
    dark_basename = file_basename(dark_file.raw_filename)
    mg_log, '%d/%d: processing %s', $
            d + 1, n_dark_files, dark_basename, $
            name=run.logger_name, /debug

    ucomp_ut2hst, strmid(dark_basename, 0, 8), strmid(dark_basename, 9, 6), $
                  hst_date=hst_date, hst_time=hst_time

    hst_dtime = float(ucomp_decompose_time(hst_time))
    dark_time = total(hst_dtime * [1.0, 1.0 / 60.0, 1.0 / 60.0 / 60.0])

    ucomp_read_raw_data, dark_file.raw_filename, $
                         primary_data=primary_data, $
                         primary_header=primary_header, $
                         ext_data=ext_data, $
                         ext_headers=ext_headers, $
                         n_extensions=n_extensions, $
                         repair_routine=run->epoch('raw_data_repair_routine', datetime=datetime), $
                         badframes=run.badframes, $
                         metadata_fixes=run.metadata_fixes, $
                         logger=run.logger_name

    ext_data = float(ext_data)

    ; use the primary header of the first dark file as the template for the
    ; primary header of the master dark file
    if (d eq 0L) then first_primary_header = primary_header

    ucomp_average_darkfile, primary_header, ext_data, ext_headers, $
                            n_extensions=n_averaged_extensions, $
                            exptime=averaged_exptime, $
                            gain_mode=averaged_gain_mode, $
                            nuc=averaged_nuc, $
                            run=run

    ; move demoted_keywords from primary header to extension headers
    for k = 0L, n_elements(demoted_keywords) - 1L do begin
      value = ucomp_getpar(primary_header, demoted_keywords[k], comment=comment)
      type = size(value, /type)
      after = k eq 0L ? 'T_RACK' : demoted_keywords[k]
      for e = 0L, n_averaged_extensions - 1L do begin
        ext_header = ext_headers[e]
        ucomp_addpar, ext_header, $
                      'RAWFILE', $
                      file_basename(dark_file.raw_filename)
        ucomp_addpar, ext_header, $
                      demoted_keywords[k], $
                      value, $
                      comment=comment, $
                      format=type eq 4 || type eq 5 ? '(F0.3)' : !null, $
                      after=after
        ext_headers[e] = ext_header
      endfor
    endfor

    averaged_raw_files = strarr(n_averaged_extensions) + file_basename(dark_file.raw_filename)

    dark_headers->add, ext_headers, /extract

    dark_times->add, fltarr(n_averaged_extensions) + dark_time, /extract

    dark_exposures->add, averaged_exptime, /extract
    dark_gain_modes->add, averaged_gain_mode, /extract
    dark_nucs->add, averaged_nuc, /extract
    dark_raw_files->add, averaged_raw_files, /extract

    for e = 0L, n_averaged_extensions - 1L do begin
      dark_extnames->add, strmid(file_basename(dark_files[d].raw_filename), 9, 6)

      dark_image = reform(ext_data[*, *, *, *, e])

      rcam_means += total(total(reform(dark_image[*, *, *, 0]), $
                                1, $
                                /preserve_type, /nan), $
                          1, $
                          /preserve_type, /nan)
      n_rcam += 1L
      tcam_means += total(total(reform(dark_image[*, *, *, 1]), $
                                1, $
                                /preserve_type, /nan), $
                          1, $
                          /preserve_type, /nan)
      n_tcam += 1L

      dark_image = mean(dark_image, dimension=3, /nan)
      dark_data->add, dark_image
    endfor

    dims = size(dark_image, /dimensions)
    r_outer = run->epoch('field_radius', datetime=datetime)
    field_mask = ucomp_field_mask(dims[0:1], r_outer)
    field_mask_indices = where(field_mask, /null)
    rcam_image = dark_image[*, *, 0]
    tcam_image = dark_image[*, *, 1]

    dark_file.rcam_median_linecenter = median(rcam_image[field_mask_indices])
    dark_file.tcam_median_linecenter = median(tcam_image[field_mask_indices])

    tu_c0arr = ucomp_getpar(primary_header, 'TU_C0ARR', /float)
    tu_c0pcb = ucomp_getpar(primary_header, 'TU_C0PCB', /float)
    tu_c1arr = ucomp_getpar(primary_header, 'TU_C1ARR', /float)
    tu_c1pcb = ucomp_getpar(primary_header, 'TU_C1PCB', /float)
    dark_info->add, {times: ucomp_dateobs2hours(ucomp_getpar(primary_header, 'DATE-OBS')), $
                     tu_c0arr: float(tu_c0arr), $
                     tu_c0pcb: float(tu_c0pcb), $
                     tu_c1arr: float(tu_c1arr), $
                     tu_c1pcb: float(tu_c1pcb)}
  endfor

  ; remove keywords that were moved from the primary header to the extension
  ; headers from the primary header
  for k = 0L, n_elements(demoted_keywords) - 1L do begin
    sxdelpar, first_primary_header, demoted_keywords[k]
  endfor

  ; add a few more keywords to master dark file primary header
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

  dark_times_array      = dark_times->toArray()
  dark_exposures_array  = dark_exposures->toArray()
  dark_gain_modes_array = dark_gain_modes->toArray()
  dark_nucs_array = dark_nucs->toArray()
  dark_raw_files_array  = dark_raw_files->toArray()
  obj_destroy, [dark_times, $
                dark_exposures, $
                dark_gain_modes, $
                dark_nucs, $
                dark_raw_files]

  ; write master dark FITS file in the process_basedir/level1

  output_basename = string(run.date, format='(%"%s.ucomp.dark.fts")')
  output_filename = filepath(output_basename, root=l1_dir)

  fits_open, output_filename, output_fcb, /write
  fits_write, output_fcb, 0, first_primary_header
  for d = 0L, n_elements(dark_headers) - 1L do begin
    fits_write, output_fcb, $
                dark_data[d], $
                dark_headers[d], $
                extname=dark_extnames[d]
  endfor

  mkhdr, times_header, dark_times_array, /extend, /image
  fits_write, output_fcb, dark_times_array, times_header, extname='Times'

  mkhdr, exposures_header, dark_exposures_array, /extend, /image
  fits_write, output_fcb, dark_exposures_array, exposures_header, extname='Exposures'

  mkhdr, gain_modes_header, dark_gain_modes_array, /extend, /image
  fits_write, output_fcb, dark_gain_modes_array, gain_modes_header, extname='Gain modes'

  mkhdr, nucs_header, dark_nucs_array, /extend, /image
  fits_write, output_fcb, dark_nucs_array, nucs_header, extname='NUCs'

  fits_close, output_fcb

  averaged_dark_images = dark_data->toArray(/transpose)

  ; TODO: create std dev dark image (where to put it?)

  ; cache darks
  cal = run.calibration
  cal->cache_darks, darks=averaged_dark_images, $
                    times=dark_times_array, $
                    exptimes=dark_exposures_array, $
                    gain_modes=dark_gain_modes_array, $
                    nucs=dark_nucs_array, $
                    raw_files=dark_raw_files_array

  rcam_means /= (n_rcam gt 0L ? n_rcam : 1L)
  rcam_means /= nx * ny
  tcam_means /= (n_tcam gt 0L ? n_tcam : 1L)
  tcam_means /= nx * ny

  for p = 0L, n_pol_states - 1L do begin
    mg_log, '%d RCAM dark means, pol state %d: %0.1f', $
            n_rcam, p, rcam_means[p], $
            name=run.logger_name, /debug
  endfor

  for p = 0L, n_pol_states - 1L do begin
    mg_log, '%d TCAM dark means, pol state %d: %0.1f', $
            n_tcam, p, tcam_means[p], $
            name=run.logger_name, /debug
  endfor

  mg_log, /check_math, name=run.logger_name, /warn
  ucomp_dark_plots, dark_info->toArray(), averaged_dark_images, run=run
  math_errors = check_math()  ; plotting causes math errors I can't eliminate

  done:
  if (obj_valid(dark_headers)) then obj_destroy, dark_headers
  if (obj_valid(dark_data)) then obj_destroy, dark_data
  if (obj_valid(dark_extnames)) then obj_destroy, dark_extnames
  if (obj_valid(dark_info)) then obj_destroy, dark_info
end
