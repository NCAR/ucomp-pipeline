; docformat = 'rst'

;+
; Perform the steps of the end-of-day processing.
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
  ;ucomp_pipeline_step, 'ucomp_make_darks', run=run

  for w = 0L, n_elements(wave_regions) - 1L do begin
    ;ucomp_pipeline_step, 'ucomp_make_flats', wave_regions[w], run=run
    ucomp_pipeline_step, 'ucomp_check_sci_quality', wave_regions[w], run=run
    ucomp_pipeline_step, 'ucomp_l1_process', wave_regions[w], run=run
    ucomp_pipeline_step, 'ucomp_check_gbu', wave_regions[w], run=run
  endfor

  ucomp_pipeline_step, 'ucomp_l1_engineering_plots', run=run


  ;== level 2

  ; TODO: add level 2 steps
end
