; docformat = 'rst'

;+
; Compare two text files.
;
; :Params:
;   standard_path : in, required, type=string
;     filename in standards
;   result_path : in, required, type=string
;     filename of result
;   logger_name : in, required, type=string
;     logger name to send warnings to
;
; :Keywords:
;   status : out, optional, type=integer
;     set to a named variable to retrieve whether the files are equivalent, 0
;     for the same, 1 for not
;-
pro ucomp_compare_text, standard_path, result_path, logger_name, status=status
  compile_opt strictarr

  status = 0L
  n_result_lines = file_lines(result_path)
  n_standard_lines = file_lines(standard_path)
  if (n_result_lines ne n_standard_lines) then begin
    status = 1L
    return
  endif
  if (n_result_lines eq 0 && n_standard_lines eq 0) then begin
    status = 0L
    return
  endif

  result = strarr(n_result_lines)
  openr, result_lun, result_path, /get_lun
  readf, result_lun, result
  free_lun, result_lun

  standard = strarr(n_standard_lines)
  openr, standard_lun, standard_path, /get_lun
  readf, standard_lun, standard
  free_lun, standard_lun

  status = array_equal(result, standard) eq 0
end
