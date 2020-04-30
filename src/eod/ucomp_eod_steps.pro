; docformat = 'rst'

pro ucomp_eod_steps, run=run
  compile_opt strictarr

  ;== level 1

  ucomp_pipeline_step, 'ucomp_make_raw_inventory', run=run
  ucomp_pipeline_step, 'ucomp_check_cal_quality', run=run

  wave_types = run->config('options/wave_types')
  for w = 0L, n_elements(wave_types) - 1L do begin
    ucomp_pipeline_step, 'ucomp_check_sci_quality', wave_types[w], run=run
    ucomp_pipeline_step, 'ucomp_make_darks', run=run
    ucomp_pipeline_step, 'ucomp_make_flats', wave_types[w], run=run
    ucomp_pipeline_step, 'ucomp_l1_process', wave_types[w], run=run
    ucomp_pipeline_step, 'ucomp_check_gbu', wave_types[w], run=run
  endfor

  ucomp_l1_engineering_plots, run=run


  ;== level 2

  ; TODO: add level 2 steps
end
