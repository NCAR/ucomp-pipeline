; docformat = 'rst'

;+
; Process a UCoMP science file.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_process_file, file, run=run
  compile_opt strictarr

  run.datetime = string(file.hst_date, file.hst_time, format='(%"%s.%s")')
  clock_id = run->start('ucomp_read_raw_data')
  ucomp_read_raw_data, file.raw_filename, $
                       primary_header=primary_header, $
                       ext_data=data, $
                       ext_headers=headers, $
                       repair_routine=run->epoch('raw_data_repair_routine')
  !null = run->stop(clock_id)

  data = float(data)

  ucomp_l1_step, 'ucomp_average_data', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_stray_light', $
                 file, primary_header, data, headers, run=run

  ucomp_l1_step, 'ucomp_apply_dark', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_camera_correction', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_apply_gain', $
                 file, primary_header, data, headers, run=run

  ucomp_l1_step, 'ucomp_continuum_correction', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_alignment', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_demodulation', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_combine_beams', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_rotate_north_up', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_masking', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_polarimetric_correction', $
                 file, primary_header, data, headers, run=run

  l1_dirname = filepath('', $
                         subdir=[run.date, 'level1'], $
                         root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name

  l1_filename = filepath(file.l1_basename, root=l1_dirname)

  clock_id = run->start('ucomp_write_fits_file')
  ucomp_write_fits_file, l1_filename, primary_header, data, headers
  !null = run->stop(clock_id)

  ucomp_create_intensity, file, data, run=run

  obj_destroy, headers
end
