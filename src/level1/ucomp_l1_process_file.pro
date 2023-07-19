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
    if (!error_state.name eq 'IDL_M_USER_ERR') then begin
      ; this is when a routine exited by calling MESSAGE from one of the steps
      ; of the level 1 processing -- if there was an actual error, it is the
      ; responsibility of the failing routine to issue a MG_LOG, /ERROR
      pos = strpos(!error_state.msg, ':')
      if (pos lt 0L) then begin
        mg_log, !error_state.msg, name=run.logger_name, /warn
      endif else begin
        routine_name = strmid(!error_state.msg, 0, pos)
        mg_log, strmid(!error_state.msg, pos + 2L), $
                name=run.logger_name, $
                from=routine_name, $
                /warn
      endelse
      mg_log, 'skipping rest of level 1 processing for file', $
              name=run.logger_name, /warn
    endif else begin
      catch, /cancel
      message, /reissue_last
    endelse
    goto, done
  endif

  run.datetime = strmid(file_basename(file.raw_filename), 0, 15)
  clock_id = run->start('ucomp_read_raw_data')
  ucomp_read_raw_data, file.raw_filename, $
                       primary_header=primary_header, $
                       ext_data=data, $
                       ext_headers=headers, $
                       repair_routine=run->epoch('raw_data_repair_routine'), $
                       badframes=run.badframes, $
                       all_zero=all_zero, $
                       logger=run.logger_name
  file.all_zero = all_zero
  !null = run->stop(clock_id)

  l1_dirname = filepath('', $
                        subdir=[run.date, 'level1'], $
                        root=run->config('processing/basedir'))
  ucomp_mkdir, l1_dirname, logger_name=run.logger_name

  if (run->config('quality/perform_check') && run->epoch('perform_quality_check')) then begin
    ucomp_l1_step, 'ucomp_l1_check_quality', $
                   file, primary_header, data, headers, run=run
    if (~file.ok) then begin
      conditions = ucomp_quality_conditions(file.wave_region, run=run)
      bad_condition_indices = where(file.quality_bitmask and conditions.mask, /null)
      bad_conditions = strjoin(strmid(conditions[bad_condition_indices].checker, 14), '|')
      mg_log, 'skipping for poor quality (%s)', bad_conditions, $
              name=run.logger_name, /warn
      goto, done
    endif
  endif else begin
    mg_log, 'skipping quality check', name=run.logger_name, /debug
  endelse

  step_number = 1L

  ; remove comments from primary header
  ; TODO: maybe this is not necessary?
  sxdelpar, primary_header, 'COMMENT'

  ucomp_l1_step, 'ucomp_l1_average_data', $
                 file, primary_header, data, headers, step_number=step_number, run=run
  ucomp_l1_step, 'ucomp_l1_camera_linearity', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_apply_dark', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  if (run->config('centering/step_order') eq 'pre-gaincorrection') then begin
    ucomp_l1_step, 'ucomp_l1_find_alignment', $
                    file, primary_header, data, headers, step_number=step_number, run=run
  endif

  ucomp_l1_step, 'ucomp_l1_apply_gain', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_camera_correction', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_continuum_correction', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_demodulation', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_distortion', $
                 file, primary_header, data, headers, step_number=step_number, run=run

  if (run->config('centering/step_order') eq 'post-distortion') then begin
    ucomp_l1_step, 'ucomp_l1_find_alignment', $
                   file, primary_header, data, headers, step_number=step_number, run=run
  endif

  ucomp_l1_step, 'ucomp_l1_continuum_subtraction', $
                 file, primary_header, data, headers, $
                 backgrounds, background_headers, $
                 step_number=step_number, run=run
  ucomp_l1_step, 'ucomp_l1_debanding', $
                 file, primary_header, data, headers, $
                 backgrounds, background_headers, $
                 step_number=step_number, run=run
  ; ucomp_l1_step, 'ucomp_l1_despiking', $
  ;                 file, primary_header, data, headers, $
  ;                 backgrounds, background_headers, $
  ;                 step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_apply_alignment', $
                 file, primary_header, data, headers, $
                 backgrounds, background_headers, $
                 step_number=step_number, run=run
  ucomp_l1_step, 'ucomp_l1_combine_cameras', $
                 file, primary_header, data, headers, $
                 backgrounds, background_headers, $
                 step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_masking', $
                 file, primary_header, data, headers, $
                 backgrounds, background_headers, $
                 step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_polarimetric_correction', $
                 file, primary_header, data, headers, $
                 backgrounds, background_headers, $
                 step_number=step_number, run=run
  ucomp_l1_step, 'ucomp_l1_sky_transmission', $
                 file, primary_header, data, headers, $
                 backgrounds, background_headers, $
                 step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_promote_header', $
                 file, primary_header, data, headers, $
                 backgrounds, background_headers, $
                 step_number=step_number, run=run

  ucomp_l1_step, 'ucomp_l1_check_gbu', $
                 file, primary_header, data, headers, $
                 backgrounds, background_headers, $
                 run=run

  l1_filename = filepath(file.l1_basename, root=l1_dirname)
  ucomp_write_fits_file, l1_filename, $
                         primary_header, $
                         data, headers, $
                         backgrounds, background_headers

  l1_intensity_filename = filepath(file.l1_intensity_basename, root=l1_dirname)
  ucomp_write_fits_file, l1_intensity_filename, $
                         primary_header, $
                         data, headers, $
                         backgrounds, background_headers, $
                         /intensity
  file.wrote_l1 = 1B

  ucomp_write_intensity_image, file, data, primary_header, run=run
  ucomp_write_intensity_image, file, data, primary_header, run=run, /enhanced
  ucomp_write_iquv_image, data, file.l1_basename, file.wave_region, file.wavelengths, $
                          occulter_radius=file.occulter_radius, $
                          run=run
  ucomp_write_all_iquv_image, file, data, run=run

  done:
  if (obj_valid(headers)) then obj_destroy, headers
  if (obj_valid(background_headers)) then obj_destroy, background_headers
end
