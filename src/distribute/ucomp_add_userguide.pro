; docformat = 'rst'

;+
; Find full path to user guide and add it to the given list of files if its
; location is specified and present.
;
; :Params:
;   file_list : in, required, type=list
;     list to add user guide filename to
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_add_userguide, files_list, run=run
  compile_opt strictarr

  docs_dir = run->config('documentation/dir')
  if (n_elements(docs_dir) eq 0L) then begin
    mg_log, 'no documentation directory specified', $
            name=run.logger_name, /warn
    goto, done
  endif

  userguide_version = run->epoch('doc_version')
  userguide_basename = string(userguide_version, $
                              format='ucomp-user-guide.v%s.pdf')
  userguide_filename = filepath(userguide_basename, $
                                root=docs_dir)
  if (file_test(userguide_filename, /regular)) then begin
    files_list->add, userguide_filename
  endif else begin
    mg_log, 'user guide does not exist', name=run.logger_name, /warn
  endelse

  done:
end
