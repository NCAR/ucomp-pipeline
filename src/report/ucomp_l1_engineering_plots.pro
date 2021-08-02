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

  ucomp_wave_region_histogram, filepath(string(run.date, $
                                               format='(%"%s.ucomp.wave_regions.png")'), $
                                      subdir=ucomp_decompose_date(run.date), $
                                      root=engineering_basedir), $
                               run=run
  ucomp_data_type_histogram, filepath(string(run.date, $
                                             format='(%"%s.ucomp.data_types.png")'), $
                                      subdir=ucomp_decompose_date(run.date), $
                                      root=engineering_basedir), $
                             run=run

  ucomp_log_centering_info, filepath(string(run.date, $
                                            format='(%"%s.ucomp.centering.log")'), $
                                      subdir=ucomp_decompose_date(run.date), $
                                     root=engineering_basedir), $
                            run=run
end
