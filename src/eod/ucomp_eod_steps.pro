; docformat = 'rst'

;+
; Perform the steps of the end-of-day processing.
;
; :Params:
;   wave_regions : in, required, type=strarr
;     wave regions, e.g., ["1074", "1079"]
;
; :Keywords:
;   run : in, required, type=object
;     KCor run object
;-
pro ucomp_eod_steps, wave_regions, run=run
  compile_opt strictarr

  ;== level 1

  ucomp_pipeline_step, 'ucomp_make_raw_inventory', run=run
  ucomp_pipeline_step, 'ucomp_raw_plots', run=run
  ucomp_pipeline_step, 'ucomp_calibration_steps', run=run

  for w = 0L, n_elements(wave_regions) - 1L do begin
    ucomp_pipeline_step, 'ucomp_l1_process', wave_regions[w], run=run
    ucomp_pipeline_step, 'ucomp_write_quality', wave_regions[w], run=run
    ucomp_pipeline_step, 'ucomp_write_gbu', wave_regions[w], run=run
    ucomp_pipeline_step, 'ucomp_write_l1_movies', wave_regions[w], run=run
  endfor

  ucomp_pipeline_step, 'ucomp_l1_engineering_plots', run=run
  ucomp_pipeline_step, 'ucomp_validate', 'l1', run=run

  ;== level 2

  for w = 0L, n_elements(wave_regions) - 1L do begin
    ucomp_pipeline_step, 'ucomp_l2_process', wave_regions[w], run=run
    ucomp_pipeline_step, 'ucomp_write_l2_movies', wave_regions[w], run=run
  endfor

  ucomp_pipeline_step, 'ucomp_l2_temperature_maps', run=run
end
