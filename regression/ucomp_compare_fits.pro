; docformat = 'rst'

;+
; Compare two FITS files.
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
pro ucomp_compare_fits, standard_path, result_path, logger_name, status=status
  compile_opt strictarr

  status = 0L
  ignore_keywords = ['DATE_DP', 'DPSWID', 'DATE_DP2', 'DPSWID2']
  is_different = mg_fits_diff(standard_path, result_path, $
                              name1=file_basename(standard_path), $
                              name2='new', $
                              ignore_keywords=ignore_keywords, $
                              tolerance=1.0e-5, $
                              differences=differences, $
                              error_msg=error_msg)

  if (error_msg ne '') then begin
    status = 1L
    mg_log, error_msg, name=logger_name, /warn
  endif

  if (is_different) then begin
    status = 1L
    mg_log, '%s differs from standard', file_basename(result_path), $
            name=logger_name, /warn
    for d = 0L, n_elements(differences) - 1L do begin
      mg_log, differences[d], name=logger_name, /warn
    endfor
  endif
end
