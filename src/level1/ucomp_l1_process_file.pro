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
    if (!error_state.name eq 'IDL_M_USER_ERR') then begin
      mg_log, 'skipping rest of level 1 processing for file', $
              name=run.logger_name, /warn
    endif else begin
      catch, /cancel
      message, /reissue_last
    endelse
    goto, done
  endif

  run.datetime = string(file.hst_date, file.hst_time, format='(%"%s.%s")')
  clock_id = run->start('ucomp_read_raw_data')
  ucomp_read_raw_data, file.raw_filename, $
                       primary_header=primary_header, $
                       ext_data=data, $
                       ext_headers=headers, $
                       repair_routine=run->epoch('raw_data_repair_routine'), $
                       logger_name=run.logger_name
  !null = run->stop(clock_id)

  l1_dirname = filepath('', $
                        subdir=[run.date, 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name

  ucomp_l1_step, 'ucomp_l1_check_quality', $
                 file, primary_header, data, headers, run=run
  if (~file.ok) then begin
    mg_log, 'skipping for poor quality', name=run.logger_name
    goto, done
  endif

  step_number = 1L

  ucomp_l1_step, 'ucomp_l1_average_data', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_camera_correction', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_apply_dark', $
                 file, primary_header, data, headers, step_number=step_number, run=run
  ucomp_l1_step, 'ucomp_l1_camera_linearity', $
                 file, primary_header, data, headers, step_number=step_number, run=run
  ucomp_l1_step, 'ucomp_l1_apply_gain', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_continuum_correction', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_demodulation', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_distortion', $
                 file, primary_header, data, headers, step_number=step_number, run=run
  ucomp_l1_step, 'ucomp_l1_find_alignment', $
                 file, primary_header, data, headers, step_number=step_number, run=run
  ucomp_l1_step, 'ucomp_l1_continuum_subtraction', $
                 file, primary_header, data, headers, step_number=step_number, run=run
  ucomp_l1_step, 'ucomp_l1_debanding', $
                 file, primary_header, data, headers, step_number=step_number, run=run
  ucomp_l1_step, 'ucomp_l1_apply_alignment', $
                 file, primary_header, data, headers, step_number=step_number, run=run
  ucomp_l1_step, 'ucomp_l1_combine_cameras', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_masking', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_polarimetric_correction', $
                 file, primary_header, data, headers, step_number=step_number, run=run
  ucomp_l1_step, 'ucomp_l1_sky_transmission', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_promote_header', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_check_gbu', $
                 file, primary_header, data, headers, run=run

  l1_filename = filepath(file.l1_basename, root=l1_dirname)

  ucomp_write_fits_file, l1_filename, primary_header, data, headers
  ucomp_write_intensity_gif, file, data, run=run
  ucomp_write_iquv_gif, file, data, run=run

  done:
  if (obj_valid(headers)) then obj_destroy, headers
end
