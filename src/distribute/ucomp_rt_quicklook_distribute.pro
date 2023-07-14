; docformat = 'rst'

;+
; Distribute quicklook files to their destination.
;
; :Params:
;   files : in, required, type=objarr or !null
;     array of `ucomp_file` objects to distribute or `!null` if none to
;     distribute
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_rt_quicklook_distribute, files, run=run
  compile_opt strictarr

  if (n_elements(files) eq 0L) then begin
    mg_log, 'no quicklook files to distribute', name=run.logger, /info
    goto, done
  endif

  ; TODO: distribute quicklook files to where they need to go
  mg_log, 'not implemented', name=run.logger, /warn

  done:
end
