; docformat = 'rst'

;+
; Do the L2 -> L3 processing.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l3_process, run=run
  compile_opt strictarr

  mg_log, 'L3 processing...', name=run.logger_name, /info

  l2_dir = filepath('', $
                    subdir=[run.date, 'level2'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir, /directory)) then begin
    mg_log, 'no level2 directory, exiting', name=run.logger_name, /warn
    goto, done
  endif

  l3_dir = filepath('', $
                    subdir=[run.date, 'level3'], $
                    root=run->config('processing/basedir'))
  if (~file_test(l3_dir, /directory)) then ucomp_mkdir, l3_dir, logger_name=run.logger_name

  ; create density files
  ucomp_l3_file_step, 'ucomp_l3_density', run=run

  done:
end
