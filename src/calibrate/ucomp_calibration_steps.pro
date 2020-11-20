; docformat = 'rst'

;+
; Perform the steps of the calibration. Assumed that a raw inventory has
; already been done.
;
; :Keywords:
;   run : in, required, type=object
;     KCor run object
;-
pro ucomp_calibration_steps, run=run
  compile_opt strictarr

  ucomp_pipeline_step, 'ucomp_check_cal_quality', run=run

  ucomp_pipeline_step, 'ucomp_make_darks', run=run

  wave_regions = run->config('options/wave_regions')
  for w = 0L, n_elements(wave_regions) - 1L do begin
    ucomp_pipeline_step, 'ucomp_make_flats', wave_regions[w], run=run
  endfor

  ucomp_pipeline_step, 'ucomp_polarimetric_calibration', run=run

  ucomp_pipeline_step, 'ucomp_write_calfile', run=run
end
