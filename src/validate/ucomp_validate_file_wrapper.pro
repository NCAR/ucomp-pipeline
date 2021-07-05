; docformat = 'rst'

;+
; Validate a FITS file against its specification.
;
; :Params:
;   date : in, required, type=string
;     date in the format "YYYYMMDD"
;   config_filename : in, required, type=string
;     filename of the configuration file
;   level : in, required, type=integer
;     level of `filename`, i.e., 0, 1, or 2
;   filename_string : in, required, type=str
;     filenames of the files to be checked as long space-delimited string
;-
pro ucomp_validate_file_wrapper, date, config_filename, level, filename_string
  compile_opt strictarr

  run = ucomp_run(date, 'validate', config_filename, /no_log)
  if (not obj_valid(run)) then goto, done

  option_name = string(level, format='(%"validation/l%d_specification")')
  header_spec_filename = run->config(option_name)

  if (n_elements(header_spec_filename) eq 0L) then begin
    print, 'no spec filename found for ' + option_name
    goto, done
  endif

  filenames = strsplit(filename_string, /extract, count=n_files)
  for f = 0L, n_files - 1L do begin
    is_valid = ucomp_validate_file(filenames[f], $
                                   header_spec_filename, $
                                   error_msg=error_msg)
    print, file_basename(filenames[f]), is_valid ? 'valid' : 'not valid', $
           format='(%"%s: %s")'
    if (~is_valid) then begin
      print, transpose('  ' + error_msg)
    endif
  endfor

  done:
  if (obj_valid(run)) then obj_destroy, run
end
