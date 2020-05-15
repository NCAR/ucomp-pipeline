; docformat = 'rst'

;+
; Create a directory, if needed, with the correct permissions.
;
; :Params:
;   dir : in, required, type=string
;     directory to be created, if it doesn't already exist
;
; :Keywords:
;   logger_name : in, optional, type=string
;     logger name to send error messages to
;-
pro ucomp_mkdir, dir, logger_name=logger_name
  compile_opt strictarr

  if (~file_test(dir, /directory)) then begin
    file_mkdir, dir
    ucomp_fix_permissions, dir, /directory, logger_name=logger_name
  endif
end
