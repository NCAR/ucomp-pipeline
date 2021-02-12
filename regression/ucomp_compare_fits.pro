; docformat = 'rst'

;+
; Compare two FITS files.
;
; :Params:
;   result_path : in, required, type=string
;     filename of result
;   standard_path : in, required, type=string
;     filename in standards
;   logger_name : in, required, type=string
;     logger name to send warnings to
;-
pro ucomp_compare_fits, result_path, standard_path, logger_name
  compile_opt strictarr

  ignore_keywords = ['DATE_DP', 'DPSWID']
  is_different = mg_fits_diff(result_path, standard_path, $
                              ignore_keywords=ignore_keywords, $
                              tolerance=1.0e-5, $
                              differences=differences, $
                              error_msg=error_msg)

  if (error_msg ne '') then begin
    mg_log, error_msg, name=logger_name, /warn
  endif

  if (is_different) then begin
    mg_log, '%s differs', file_basename(result_path), name=logger_name, /warn
    for d = 0L, n_elements(differences) - 1L do begin
      mg_log, differences[d], name=logger_name, /warn
    endfor
  endif
end
