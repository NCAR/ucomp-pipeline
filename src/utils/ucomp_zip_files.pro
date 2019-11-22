; docformat = 'rst'

;+
; Zip some files.
;
; :Params:
;   glob : in, required, type=string
;     filename or glob indicating file(s) to zip
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_zip_files, glob, run=run
  compile_opt strictarr

  unzipped_files = file_search(glob, count=n_unzipped_files)
  if (n_unzipped_files gt 0L) then begin
    gzip_cmd = string(run->config('externals/gzip'), glob, $
                      format='(%"%s %s")')
    spawn, gzip_cmd, result, error_result, exit_status=status
    if (status ne 0L) then begin
      mg_log, 'problem zipping files with command: %s', gzip_cmd, $
                name=run.logger_name, /error
      mg_log, '%s', strjoin(error_result, ' '), name=run.logger_name, /error
    endif
  endif
end
