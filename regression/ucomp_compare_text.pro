; docformat = 'rst'

;+
; Compare two text files.
;
; :Params:
;   result_path : in, required, type=string
;     filename of result
;   standard_path : in, required, type=string
;     filename in standards
;   logger_name : in, required, type=string
;     logger name to send warnings to
;-
pro ucomp_compare_text, result_path, standard_path, logger_name
  compile_opt strictarr

  mg_log, 'comparing text files not implemented', name=logger_name, /warn
end