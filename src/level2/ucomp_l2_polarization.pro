; docformat = 'rst'
 
;+
; Produce the polarization images:
;
; - integrated intensity
; - integrated Q
; - integrated U
; - integrated L
;
; :Params:
;   file : in, required, type=object
;     UCoMP file object
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_l2_polarization, file, run=run
  compile_opt strictarr

  ; TODO: implement
  mg_log, 'not implemented', name=run.logger_name, /warn
end
