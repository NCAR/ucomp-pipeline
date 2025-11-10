; docformat = 'rst'

pro ucomp_check_contin, date, config_filename
  compile_opt strictarr

  run = ucomp_run(date, 'contin', config_filename)

  mg_log, 'checking %d for CONTIN', date, name=run.logger_name, /info

  l0_dir = filepath(date, root=run->config('raw/basedir'))
  raw_files = file_search(filepath('*.fts', root=l0_dir), count=n_raw_files)

  for f = 0L, n_raw_files - 1L do begin
    contin = ''
    fits_open, raw_files[f], fcb
    basename = file_basename(raw_files[f])
    mg_log, '%d/%d: %s...', f + 1, n_raw_files, basename, $
            name=run.logger_name, /info
    for e = 1L, fcb.nextend do begin
      fits_read, fcb, data, header, exten_no=e
      new_contin = sxpar(header, 'CONTIN')
      if (contin eq '') then contin = new_contin else begin
        if (contin ne new_contin) then begin
          mg_log, '%s: %s to %s at ext %d', $
                  basename, contin, new_contin, e, $
                  name=run.logger_name, /error
        endif
      endelse
    endfor
    fits_close, fcb
  endfor

  obj_destroy, run
end
