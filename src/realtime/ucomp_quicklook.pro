; docformat = 'rst'

;+
; Produce a quicklook for a given L0 file.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_quicklook, file, run=run
  compile_opt strictarr

  ; TODO: implement
  mg_log, 'not implemented', name=run.logger, /warn
end
