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

  catch, error
  if (error ne 0L) then begin
    mg_log, !error_state.msg, name=run.logger_name, /warn
    mg_log, 'skipping rest of level 1 processing for file', name=run.logger_name, /warn
    goto, done
  endif

  run.datetime = string(file.hst_date, file.hst_time, format='(%"%s.%s")')
  clock_id = run->start('ucomp_read_raw_data')
  ucomp_read_raw_data, file.raw_filename, $
                       primary_header=primary_header, $
                       ext_data=data, $
                       ext_headers=headers, $
                       repair_routine=run->epoch('raw_data_repair_routine')
  !null = run->stop(clock_id)

  data = float(data)

  l1_dirname = filepath('', $
                        subdir=[run.date, 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name


  ucomp_l1_step, 'ucomp_l1_average_data', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_l1_stray_light', $
                 file, primary_header, data, headers, run=run

  ucomp_l1_step, 'ucomp_l1_apply_dark', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_l1_camera_correction', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_l1_apply_gain', $
                 file, primary_header, data, headers, run=run

  ucomp_l1_step, 'ucomp_l1_continuum_correction', $
                 file, primary_header, data, headers, run=run

  ucomp_l1_step, 'ucomp_l1_demodulation', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_l1_continuum_subtraction', $
                 file, primary_header, data, headers, run=run

  ucomp_l1_step, 'ucomp_l1_alignment', $
                 file, primary_header, data, headers, run=run
  ucomp_l1_step, 'ucomp_l1_masking', $
                 file, primary_header, data, headers, run=run

  ucomp_l1_step, 'ucomp_l1_polarimetric_correction', $
                 file, primary_header, data, headers, run=run

  ucomp_l1_step, 'ucomp_l1_promote_header', $
                 file, primary_header, data, headers, run=run

  l1_filename = filepath(file.l1_basename, root=l1_dirname)

  clock_id = run->start('ucomp_write_fits_file')
  ucomp_write_fits_file, l1_filename, primary_header, data, headers
  !null = run->stop(clock_id)

  ucomp_create_intensity, file, data, run=run, /occulter_annotation

  done:
  if (obj_valid(headers)) then obj_destroy, headers
end
