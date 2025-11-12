; docformat = 'rst'

pro ucomp_check_notboth_contin, date, config_filename
  compile_opt strictarr

  wave_region = '1079'

  run = ucomp_run(date, 'contin', config_filename)

  mg_log, 'checking %d for CONTIN', date, name=run.logger_name, /info

  l0_dir = filepath(date, root=run->config('raw/basedir'))
  raw_files = file_search(filepath('*.fts', root=l0_dir), count=n_raw_files)

  for f = 0L, n_raw_files - 1L do begin
    fits_open, raw_files[f], fcb
    basename = file_basename(raw_files[f])
    mg_log, '%d/%d: %s...', f + 1, n_raw_files, basename, $
            name=run.logger_name, /info

    fits_read, fcb, data, primary_header, exten_no=0
    wave_region = sxpar(primary_header, 'FILTER')
    if (wave_region ne '1079') then goto, file_done

    for e = 1L, fcb.nextend do begin
      fits_read, fcb, data, header, exten_no=e
      contin = sxpar(header, 'CONTIN')
      if (contin ne 'both') then begin
        mg_log, '%s: CONTIN: %s [ext %d]', basename, contin, e, $
                name=run.logger_name, /error
        goto, file_done
      endif
    endfor

    file_done:
    fits_close, fcb
  endfor

  obj_destroy, run
end
