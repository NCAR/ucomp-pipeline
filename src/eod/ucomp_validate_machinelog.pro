; docformat = 'rst'

;+
; Validate the machine log against the received level0 data. Sends missing file
; messages to the current log.
;
; :Returns:
;   returns 1 if machine log is present and valid, 0 otherwise
;
; :Keywords:
;   present : out, optional, type=boolean
;     set to a named variable to retrieve whether the machine log is present
;   n_missing_files : out, optional, type=long
;     set to a named variable to retrieve the number of files missing in the
;     raw directory, that are present in the machine log
;   n_extra_files : out, optional, type=long
;     set to a named variable to retrieve the number of files present in the
;     raw directory, but are missing in the machine log
;   n_files : out, optional, type=long
;     set to a named variable to retrieve the number of files present in the
;     raw directory
;   run : in, required, type=object
;     UCoMP run object
;-
function ucomp_validate_machinelog, present=present, $
                                    n_missing_files=n_missing_files, $
                                    n_extra_files=n_extra_files, $
                                    n_files=n_files, $
                                    run=run
  compile_opt strictarr

  present = 0B
  n_missing_files = 0L
  n_extra_files = 0L
  n_files = 0L

  raw_dir = filepath(run.date, root=run->config('raw/basedir'))
  if (~file_test(raw_dir, /directory)) then begin
    mg_log, 'raw directory does not exist', name=run.logger_name, /warn
    return, 0B
  endif

  machinelog_filename = filepath(string(run.date, format='%s.ucomp.machine.log'), $
                                 root=raw_dir)
  if (~file_test(machinelog_filename, /regular)) then return, 0B
  present = 1B

  files = file_search(filepath('*.fts*', root=raw_dir), count=n_files)
  files = file_basename(files)

  n_lines = file_lines(machinelog_filename)

  valid = 1B

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
      valid = 0B
      n_missing_files += 1L
    endif
  endfor

  for f = 0L, n_files - 1L do begin
    !null = where(files[f] eq lines, n_matches)
    if (n_matches ne 1L) then begin
      mg_log, 'missing %s in machine log', files[f], name=run.logger_name, /error
      valid = 0B
      n_extra_files += 1L
    endif
  endfor

  return, valid
end
