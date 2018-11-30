; docformat = 'rst'

;+
; Create an inventory of the raw files for a run.
;
; :Keywords:
;   run : in, required, type=object
;     KCor run object
;-
pro ucomp_make_raw_inventory, run=run
  compile_opt strictarr

  run->make_raw_inventory
end
