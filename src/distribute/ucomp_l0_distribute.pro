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

  ; send raw files to archive
  ucomp_l0_archive, run=run

  done:
  cd, original_dir
end
