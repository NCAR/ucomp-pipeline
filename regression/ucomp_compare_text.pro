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
;
; :Keywords:
;   status : out, optional, type=integer
;     set to a named variable to retrieve whether the files are equivalent, 0
;     for the same, 1 for not
;-
pro ucomp_compare_text, result_path, standard_path, logger_name, status=status
  compile_opt strictarr

  status = 0L
  mg_log, 'comparing text files not implemented', name=logger_name, /warn
end