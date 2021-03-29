; docformat = 'rst'

;+
; Validate the machine log against the received level0 data. Sends missing file
; messages to the current log.
;
; :Returns:
;   returns 1 if machine log is present, 0 otherwise
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
function ucomp_validate_machinelog, run=run
  compile_opt strictarr

  raw_dir = filepath(run.date, root=run->config('raw/basedir'))
  machinelog_filename = filepath(string(run.date, format='%s.ucomp.machine.log'), $
                                 root=raw_dir)
  if (~file_test(machinelog_filename, /regular)) then return, 0B

  files = file_search(filepath('*.fts*', root=raw_dir), count=n_files)
  files = file_basename(files)

  n_lines = file_lines(machinelog_filename)

  if (n_lines gt 0L) then begin
    lines = strarr(n_lines)
    openr, lun, machinelog_filename, /get_lun
    readf, lun, lines
    free_lun, lun
    for i = 0L, n_lines - 1L do begin
      tokens = strsplit(lines[i], /extract)
      lines[i] = tokens[0]
    endfor
  endif

  for i = 0L, n_lines - 1L do begin
    !null = where(lines[i] eq files, n_matches)
    if (n_matches ne 1L) then begin
      mg_log, 'missing %s in raw files', lines[i], name=run.logger_name, /error
    endif
  endfor

  for f = 0L, n_files - 1L do begin
    !null = where(files[f] eq lines, n_matches)
    if (n_matches ne 1L) then begin
      mg_log, 'missing %s in machine log', files[i], name=run.logger_name, /error
    endif
  endfor

  return, 1B 
end
