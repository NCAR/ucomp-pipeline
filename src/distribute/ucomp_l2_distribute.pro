; docformat = 'rst'

;+
; Package and distribute level 2 products to the appropriate locations.
;
; :Params:
;   wave_type : in, required, type=string
;     wavelength type to distribute, i.e., '1074'
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l2_distribute, wave_type, run=run
  compile_opt strictarr

  if (~run->config(wave_type + '/distribute_l2')) then begin
    mg_log, 'skipping distributing %s nm L2 data', wave_type, $
            name=run.logger, /info
    goto, done
  endif

  ; TODO: make tarball of L2 data
  ; TODO: put link to L2 tarball in HPSS directory
  ; TODO: copy L2 data into archive, etc. directories

  done:
end
