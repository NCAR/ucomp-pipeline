; docformat = 'rst'

;+
; Produce L1 engineering plots.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_engineering_plots, run=run
  compile_opt strictarr

  mg_log, 'producing engineering plots...', name=run.logger_name, /info

  engineering_basedir = run->config('engineering/basedir')
  if (n_elements(engineering_basedir) eq 0L) then begin
    mg_log, 'no engineering/basedir to save plots', name=run.logger_name, /warn
  endif

  engineering_dir = filepath('', $
                             subdir=ucomp_decompose_date(run.date), $
                             root=engineering_basedir)

  ucomp_wave_region_histogram, filepath(string(run.date, $
                                               format='(%"%s.ucomp.daily.wave_regions.png")'), $
                                      root=engineering_dir), $
                               run=run
  ucomp_data_type_histogram, filepath(string(run.date, $
                                             format='(%"%s.ucomp.daily.data_types.png")'), $
                                      root=engineering_dir), $
                             run=run
  ucomp_sgs_plots, engineering_dir, run=run
  ucomp_vcrosstalk_plots, engineering_dir, run=run

  ucomp_log_centering_info, filepath(string(run.date, $
                                            format='(%"%s.ucomp.daily.centering.log")'), $
                                     root=engineering_dir), $
                            run=run

  wave_regions = run->config('options/wave_regions')
  for w = 0L, n_elements(wave_regions) - 1L do begin
    ucomp_plot_centering_info, filepath(string(run.date, wave_regions[w], $
                                               format='(%"%s.ucomp.%s.daily.centering.gif")'), $
                                        root=engineering_dir), $
                               wave_regions[w], $
                               run=run
    ucomp_plot_temp_vs_voltage, filepath(string(run.date, wave_regions[w], $
                                                format='(%"%s.ucomp.%s.daily.temp_vs_volt.gif")'), $
                                         root=engineering_dir), $
                                wave_regions[w], $
                                run=run
  endfor
end
