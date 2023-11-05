; docformat = 'rst'

;+
; Remove all the UCoMP files for a given date in basedir/YYYY/MM/DD.
;
; :Params:
;   date : in, required, type=string
;     date to clear in the form 'YYYYMMDD'
;   basedir : in, required, type=string
;     base directory
;   name : in, required, type=string
;     name to refer to `basedir` by, i.e., archive, fullres, etc.
;
; :Keywords:
;   logger_name : in, optional, type=string
;     name of logger to send output to
;-
pro ucomp_clearday, date, basedir, name, logger_name=logger_name
  compile_opt strictarr

  files_glob = filepath('*{ucomp,UCOMP}*', $
                        subdir=ucomp_decompose_date(date), $
                        root=basedir)

  files = file_search(files_glob, count=n_files)
  if (n_files eq 0L) then begin
    mg_log, 'no files to remove in %s', name, name=logger_name, /info
  endif else begin
    mg_log, 'removing %d files in %s', n_files, name, name=logger_name, /info
    file_delete, files
  endelse
end
