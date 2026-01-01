; docformat = 'rst'

;+
; Apply distortion to the flats and write out FITS files of of these distortion
; corrected flats in the `process/YYYYMMDD/distortion` directory.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_flats_distortion, run=run
  compile_opt strictarr

  distortion_dirname = filepath('', $
                                subdir=[run.date, 'distortion'], $
                                root=run->config('processing/basedir'))
  ucomp_mkdir, distortion_dirname, logger_name=run.logger_name

  ; query run object for all the flat files
  flat_files = run->get_files(data_type='flat', count=n_flat_files)

  mg_log, 'disortion correcting %d flat files', n_flat_files, $
          name=run.logger_name, /info

  n_digits = floor(alog10(n_flat_files)) + 1L

  ; loop through the flat files and produce a new flat file that is just the
  ; distortion corrected flat
  for f = 0L, n_flat_files - 1L do begin
    file = flat_files[f]

    mg_log, mg_format('%*d/%d: correcting %s', n_digits, /simple), $
            f + 1, n_flat_files, file_basename(file.raw_filename), $
            name=run.logger_name, /info

    ; read the file
    clock_id = run->start('ucomp_read_raw_data')
    ucomp_read_raw_data, file.raw_filename, $
                         primary_header=primary_header, $
                         ext_data=data, $
                         ext_headers=headers, $
                         repair_routine=run->epoch('raw_data_repair_routine'), $
                         badframes=run.badframes, $
                         metadata_fixes=run.metadata_fixes, $
                         all_zero=all_zero, $
                         logger=run.logger_name
    file.all_zero = all_zero
    !null = run->stop(clock_id)

    ; distortion correct the file
    ucomp_l1_step, 'ucomp_l1_distortion', $
                   file, primary_header, data, headers, $
                   step_number=step_number, run=run

    ; write the file
    file->getProperty, l1_basename=basename, intermediate_name='dist'
    distortion_filename = filepath(basename, root=distortion_dirname)
    ucomp_write_fits_file, distortion_filename, $
                           primary_header, $
                           data, headers, $
                           backgrounds, background_headers, $
                           logger_name=run.logger_name
  endfor
end
