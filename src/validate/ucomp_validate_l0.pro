; docformat = 'rst'

pro ucomp_validate_l0, run=run
  compile_opt strictarr

  ; get L0 validation spec
  l0_spec_filename = run->config("validation/l0_specification")
  if (n_elements(l0_spec_filename) eq 0L) then begin
    mg_log, 'no L0 validation spec, skipping', name=run.logger_name, /info
    goto, done
  endif

  ; get list of level 0 files
  raw_dir = filepath(run.date, root=run->config('raw/basedir'))
  raw_files = file_search(filepath('*.fts*', root=raw_dir), count=n_raw_files)

  n_invalid = 0L
  for f = 0L, n_raw_files - 1L do begin
    is_valid = ucomp_validate_l0_file(raw_files[f], l0_spec_filename, $
                                      error_msg=error_msg)
    if (~is_valid) then begin
      n_invalid += 1L
      mg_log, '%s not valid', file_basename(raw_files[f]), name=run.logger_name, /warn
      for m = 0L, n_elements(error_msg) - 1L do begin
        mg_log, error_msg[m], name=run.logger_name, /warn
      endfor
    endif
  endfor

  mg_log, '%d invalid files found', n_invalid, name=run.logger_name, /info

  done:
end
