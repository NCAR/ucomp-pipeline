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

  ucomp_pipeline_step, 'ucomp_check_cal_quality', 'dark', run=run
  ucomp_pipeline_step, 'ucomp_check_cal_quality', 'flat', run=run
  ucomp_pipeline_step, 'ucomp_check_cal_quality', 'cal', run=run
  ucomp_pipeline_step, 'ucomp_write_cal_quality', run=run

  ucomp_pipeline_step, 'ucomp_make_darks', run=run

  wave_regions = run->config('options/wave_regions')
  for w = 0L, n_elements(wave_regions) - 1L do begin
    ucomp_pipeline_step, 'ucomp_make_flats', wave_regions[w], run=run
    ucomp_pipeline_step, 'ucomp_make_demod', wave_regions[w], run=run
    ucomp_pipeline_step, 'ucomp_make_darkcor_flats', wave_regions[w], run=run
  endfor
end
