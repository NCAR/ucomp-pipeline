; docformat = 'rst'

;+
; Write an inventory file of the raw files for a run.
;
; :Params:
;   filename : in, required, type=str
;     write an inventory file
;   wave_type : in, required, type=str
;     wave type of the files, i.e., '1074', etc.
;
; :Keywords:
;   run : in, required, type=object
;     KCor run object
;-
pro ucomp_write_raw_inventory, filename, wave_type, run=run
  compile_opt strictarr

  run->write_raw_inventory, filename, wave_type
end
