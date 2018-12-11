; docformat = 'rst'

;+
; Make sure given file is readable by user/group/other and writable by
; user/group.
;
; :Params:
;   filename : in, required, type=string
;     filename to check and fix
;
; :Keywords:
;   logger_name : in, optional, type=string
;     name of logger to send output to
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of the file: 0 if OK, 1 if
;     it has a bad permission that cannot be fixed by this process
;-
pro ucomp_fix_permissions, filename, logger_name=logger_name, status=status
  compile_opt strictarr

  status = 0L
  !null = file_test(filename, get_mode=mode)
  if (mode ne '664'o) then begin
    if (file_test(filename, /user)) then begin
      file_chmod, filename, '664'o
    endif else begin
      mg_log, 'bad permissions on %s', filename, name=logger_name, /error
      status = 1L
    endelse
  endif
end
