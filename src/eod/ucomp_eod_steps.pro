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

  ucomp_pipeline_step, 'ucomp_make_raw_inventory', run=run
  ucomp_pipeline_step, 'ucomp_raw_plots', run=run
  ucomp_pipeline_step, 'ucomp_calibration_steps', run=run

  ;== level 1
  if (run->config('steps/level1')) then begin
    for w = 0L, n_elements(wave_regions) - 1L do begin
      ucomp_pipeline_step, 'ucomp_l1_process', wave_regions[w], run=run
      ucomp_pipeline_step, 'ucomp_write_quality', wave_regions[w], run=run
      ucomp_pipeline_step, 'ucomp_write_gbu', wave_regions[w], run=run
      ucomp_pipeline_step, 'ucomp_write_l1_movies', wave_regions[w], run=run
    endfor

    ucomp_pipeline_step, 'ucomp_l1_engineering_plots', run=run
    ucomp_pipeline_step, 'ucomp_validate', 'l1', run=run
  endif else begin
    mg_log, 'skipping level 1 processing', name=run.logger_name, /info
  endelse

  ;== level 2
  if (run->config('steps/level2')) then begin
    for w = 0L, n_elements(wave_regions) - 1L do begin
      ucomp_pipeline_step, 'ucomp_l2_process', wave_regions[w], run=run
      ucomp_pipeline_step, 'ucomp_write_l2_movies', wave_regions[w], run=run
    endfor

    ucomp_pipeline_step, 'ucomp_l2_temperature_maps', run=run
  endif else begin
    mg_log, 'skipping level 2 processing', name=run.logger_name, /info
  endelse

  ;== level 3
  if (run->config('steps/level3')) then begin
    ucomp_pipeline_step, 'ucomp_l3_process', run=run
  endif else begin
    mg_log, 'skipping level 3 processing', name=run.logger_name, /info
  endelse
end
