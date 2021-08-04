; docformat = 'rst'

;+
; Compare two binary files.
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
pro ucomp_compare_binary, result_path, standard_path, logger_name, status=status
  compile_opt strictarr

  status = 0L

  result_info = file_info(result_path)
  standard_info = file_info(standard_path)
  if (result_info.size ne standard_info.size) then begin
    status = 1L
    return
  endif

  if (result_info.size eq 0 && standard_info.size eq 0) then begin
    status = 0L
    return
  endif

  result = bytarr(result_info.size)
  openr, lun, result_path, /get_lun
  readu, lun, result
  free_lun, lun

  standard = bytarr(standard_info.size)
  openr, lun, standard_path, /get_lun
  readu, lun, standard
  free_lun, lun

  status = array_equal(result, standard) eq 0
end
