; docformat = 'rst'

;+
; Package and distribute level 2 products to the appropriate locations.
;
; :Params:
;   wave_region : in, required, type=string
;     wavelength type to distribute, i.e., '1074'
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l2_distribute, wave_region, run=run
  compile_opt strictarr

  if (~run->config(wave_region + '/distribute_l2')) then begin
    mg_log, 'skipping distributing %s nm L2 data', wave_region, $
            name=run.logger, /info
    goto, done
  endif

  ; send L2 files to HPSS
  ucomp_l2_archive, wave_region, run=run

  ; TODO: copy L2 data into archive, etc. directories

  done:
end
