; docformat = 'rst'

;+
; Archive L1 files for given wave type on the HPSS.
;
; :Params:
;   wave_type : in, required, type=string
;     wavelength type to distribute, i.e., '1074'
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l1_archive, wave_type, run=run
  compile_opt strictarr

  if (~run->config(wave_type + '/distribute_l1')) then begin
    mg_log, 'skipping distributing %s nm L1 data', wave_type, $
            name=run.logger, /info
    goto, done
  endif

  ; TODO: make tarball of L1 data
  ; TODO: put link to L1 tarball in HPSS directory

  done:
end
