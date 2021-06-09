; docformat = 'rst'

;+
; Package and distribute level 0 products to the appropriate locations.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l0_distribute, run=run
  compile_opt strictarr

  cd, current=original_dir

  if (~run->config('raw/send_to_archive')) then begin
    mg_log, 'skipping sending raw data to archive', name=run.logger_name, /info
    goto, done
  endif

  ; send raw files to HPSS
  ucomp_l0_archive, run=run

  done:
  cd, original_dir
end
