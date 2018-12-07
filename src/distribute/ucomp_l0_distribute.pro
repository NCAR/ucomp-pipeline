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

  if (~run->config('raw/distribute')) then begin
    mg_log, 'skipping distributing raw data', name=run.logger, /info
    goto, done
  endif

  ; TODO: make tarball of L0 data
  ; TODO: put link to L0 tarball in HPSS directory

  done:
end
