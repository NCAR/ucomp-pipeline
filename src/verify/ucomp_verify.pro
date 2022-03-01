; docformat = 'rst'


;+
; Extract the date and time, if present, from the basename of a file.
;
; :Returns:
;   the date in the form "YYYYMMDD"
;
; :Params:
;   basename : in, required, type=string
;     basename of UCoMP raw or processed file
;
; :Keywords:
;   time : out, optional, type=string
;     time in the form "HHMMSS"
;-
function ucomp_verify_get_datetime, basename, time=time
  compile_opt strictarr
  on_ioerror, bad_time

  date = long(ucomp_decompose_date(strmid(basename, 0, 8)))
  time = long(ucomp_decompose_time(strmid(basename, 9, 6)))

  return, date

  bad_time:
  time = [18L, 0L, 0L]
  return, date
end


;+
; Make sure the files are for the correct date.
;-
pro ucomp_verify_check_files, run=run, status=status
  compile_opt strictarr

  status = 0L

  raw_basedir = run->config('raw/basedir')
  raw_dir = filepath(run.date, root=raw_basedir)
  files = file_search(raw_dir, '*.fts*', count=n_files)

  ut_offset = - 10.0D / 24.0D   ; shift to HST in days
  date = ucomp_decompose_date(run.date)
  date_jd = julday(date[1], date[2], date[0], 0, 0, 0)

  n_bad = 0L
  for f = 0L, n_files - 1L do begin
    basename = file_basename(files[f])
    date = ucomp_verify_get_datetime(basename, time=time)
    jd = julday(date[1], date[2], date[0], time[0], time[1], time[2]) + ut_offset
    if ((jd lt date_jd) || (jd - date_jd gt 1.0)) then begin
      n_bad += 1L
      mg_log, 'bad date/time for %s [%04d-%02d-%02dT%02d:%02d:%02dZ]', $
              basename, $
              date[0], date[1], date[2], time[0], time[1], time[2], $
              name=run.logger_name, /warn
    endif
  endfor

  if (n_bad eq 0L) then begin
    mg_log, 'dates OK for %d raw files', n_files, $
            name=run.logger_name, /info
  endif else begin
    mg_log, '%d files with bad dates', n_bad, name=run.logger_name, /warn
    status = 1L
  endelse
end


;+
; Check the permissions on the files.
;-
pro ucomp_verify_check_permissions, run=run, status=status
  compile_opt strictarr

  status = 0L
  correct_mode = '664'o

  process_basedir = run->config('processing/basedir')
  process_dir = filepath(run.date, root=process_basedir)
  files = file_search(process_dir, '*', count=n_files)

  n_bad = 0L
  for f = 0L, n_files - 1L do begin
    info = file_info(files[f])
    if (info.mode and correct_mode ne correct_mode) then n_bad += 1L
  endfor

  if (n_bad eq 0L) then begin
    mg_log, 'permissions OK for %d processed files', n_files, $
            name=run.logger_name, /info
  endif else begin
    mg_log, '%d files with bad permissions', n_bad, name=run.logger_name, /warn
    status = 1L
  endelse
end


;+
; Check the machine log against the data:
;   - filenames in the machine log match those present in the incoming
;     directory
;   - file sizes in the machine log match those present in the incoming
;     directory 
;-
pro ucomp_verify_check_logs, run=run, status=status
  compile_opt strictarr

  status = 0L

  raw_basedir = run->config('raw/basedir')
  raw_dir = filepath(run.date, root=raw_basedir)
  raw_files = file_search(filepath('*.fts', root=raw_dir), count=n_raw_files)
  raw_basenames = file_basename(raw_files)
  machine_log_filename = filepath(string(run.date, format='(%"%s.ucomp.machine.log")'), $
                                  root=raw_dir)

  if (~file_test(machine_log_filename, /regular)) then begin
    mg_log, 'machine log not present', name=run.logger_name, /warn
    status = 1L
    return
  endif

  n_ml_lines = file_lines(machine_log_filename)
  if (n_ml_lines eq 0L) then begin
    mg_log, 'machine log empty', name=run.logger_name, /warn
    status = 1L
    return
  endif

  ml_files = strarr(n_ml_lines)
  ml_sizes = ulon64arr(n_ml_lines)
  openr, lun, machine_log_filename, /get_lun
  line = ''
  for f = 0L, n_ml_lines - 1L do begin
    readf, lun, line
    tokens = strsplit(line, /extract)
    ml_files[f] = tokens[0]
    ml_sizes[f] = ulong64(tokens[1])
  endfor
  free_lun, lun

  if (n_raw_files ne n_ml_lines) then begin
    mg_log, '%d raw files and %d files in machine log', $
            n_raw_files, n_ml_lines, $
            name=run.logger_name, /warn
    status = 1L
    return
  endif

  n_bad = 0L
  for f = 0L, n_ml_lines - 1L do begin
    matching_index = where(ml_files[f] eq raw_basenames, n_matches)
    if (n_matches ne 1L) then begin
      n_bad += 1L
      status = 1L
    endif
    case 1 of
      n_matches eq 0: begin
          mg_log, 'missing %s', ml_files[f], name=run.logger_name, /warn
          n_bad += 1L
          status = 1L
        end
      n_matches eq 1: begin
          info = file_info(raw_files[matching_index[0]])
          if (info.size ne ml_sizes[f]) then begin
            n_bad += 1L
            status = 1L
            mg_log, 'bad size for %s (%d != %d)', $
                    ml_files[f], info.size, ml_sizes[f], $
                    name=run.logger_name, /warn
          endif
        end
      n_matches gt 1: begin
          mg_log, 'multiple %s files', ml_files[f], name=run.logger_name, /warn
          n_bad += 1L
          status = 1L
        end
    endcase
  endfor

  if (n_bad eq 0L) then begin
    mg_log, 'raw files match machine log', name=run.logger_name, /info
  endif else begin
    mg_log, '%d raw files not matching machine log', n_bad, name=run.logger_name, /warn
  endelse
end


;+
; Check the filenames/sizes match those on the collection server.
;-
pro ucomp_verify_check_collection_server, run=run, status=status
  compile_opt strictarr

  status = 0UL

  collection_server = run->config('verification/collection_server')
  if (n_elements(collection_server) eq 0L) then begin
    mg_log, 'no collection server specified', name=run.logger_name, /warn
    status = 11ULL
    goto, done
  endif

  collection_basedir = run->config('verification/collection_basedir')
  if (n_elements(collection_basedir) eq 0L) then begin
    mg_log, 'no collection basedir specified', name=run.logger_name, /warn
    status = 1UL
    goto, done
  endif

  ssh_options = ''
  ssh_key = run->config('verification/ssh_key')
  if (n_elements(ssh_key) gt 0L) then ssh_options += string(ssh_key, format='(%"-i %s")')

  ssh_cmd = string(ssh_options, $
                   collection_server, $
                   collection_basedir, $
                   run.date, $
                   format='(%"ssh %s %s ls %s/%s/*.fts | wc -l")')
  spawn, ssh_cmd, ssh_output, ssh_error, exit_status=ssh_status
  if (ssh_status ne 0L) then begin
    mg_log, 'problem checking raw files on %s:%s', $
            collection_server, $
            collection_basedir, $
            name=logger_name, /error
    mg_log, 'command: %s', cmd, name=run.logger_name, /error
    mg_log, '%s', strjoin(error_output, ' '), name=run.logger_name, /error
    status or= 1UL
    goto, done
  endif

  n_raw_files = long(ssh_output[0])

  raw_basedir = run->config('raw/basedir')
  raw_dir = filepath(run.date, root=raw_basedir)
  machine_log_filename = filepath(string(run.date, format='(%"%s.ucomp.machine.log")'), $
                                  root=raw_dir)
  if (~file_test(machine_log_filename, /regular)) then begin
    status or= 1UL
    mg_log, 'no machine log to check against', name=run.logger_name, /warn
    goto, done
  endif

  n_log_lines = file_lines(machine_log_filename)
  if (n_log_lines ne n_raw_files) then begin
    mg_log, '# raw files on collection server (%d) does not match # lines in machine log (%d)', $
            n_raw_files, n_log_lines, $
            name=run.logger_name, /warn
    status or= 1UL
    goto, done
  endif

  mg_log, 'number of raw files on collection server matches machine log', $
          name=run.logger_name, /info

  done:
end


;+
; Check the filenames/sizes of the tarballs match those on the archive server.
;-
pro ucomp_verify_check_archive_server, run=run, status=status
  compile_opt strictarr

  status = 0L

  archive_server = run->config('verification/archive_server')
  if (n_elements(archive_server) eq 0L) then begin
    mg_log, 'no archive server specified', name=run.logger_name, /warn
    status = 1L
    goto, done
  endif

  archive_basedir = run->config('verification/archive_basedir')
  if (n_elements(archive_basedir) eq 0L) then begin
    mg_log, 'no archive base dir specified', name=run.logger_name, /warn
    status = 1L
    goto, done
  endif

  ssh_key = run->config('verification/ssh_key')
  year = strmid(run.date, 0, 4)
  archive_dir = filepath(year, root=archive_basedir)

  l0_basename = string(run.date, format='(%"%s.ucomp.l0.tar")')
  l0_dir = filepath('', $
                    subdir=[run.date, 'level0'], $
                    root=run->config('processing/basedir'))
  status or= 2UL * ucomp_verify_check_remote_file(l0_basename, $
                                                  l0_dir, $
                                                  archive_server, $
                                                  archive_dir, $
                                                  ssh_key, $
                                                  logger_name=run.logger_name)

  ; l1_basename = string(run.date, format='(%"%s.ucomp.l1.tar")')
  ; l1_dir = filepath('', $
  ;                   subdir=[run.date, 'level1'], $
  ;                   root=run->config('processing/basedir'))
  ; status or= 2UL * ucomp_verify_check_remote_file(l1_basename, $
  ;                                                 l1_dir, $
  ;                                                 archive_server, $
  ;                                                 archive_dir, $
  ;                                                 ssh_key, $
  ;                                                 logger_name=run.logger_name)

  done:
end


;+
; Verify the integrity of the data for a given date.
;
; :Params:
;   date : in, required, type=string
;     date to process, in YYYYMMDD format
;   config_filename, in, optional, type=string
;     configuration filename to use
;
; :Keywords:
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the date: 0 for success,
;     anything else indicates a problem
;   log_filename : out, optional, type=string
;     set to a named variable to retrieve the filename of the log file for the
;     date
;-
pro ucomp_verify, date, config_filename, $
                  status=status, $
                  log_filename=log_filename
  compile_opt strictarr

  status = 0L
  logger_name = 'ucomp/verify'

  if (n_elements(config_filename) eq 0L) then begin
    mg_log, 'date argument is missing', name=logger_name, /error
    status = 1L
    goto, done
  endif

  config_fullpath = file_expand_path(config_filename)

  if (n_elements(date) eq 0L) then begin
    mg_log, 'date argument is missing', name=logger_name, /error
    status = 1L
    goto, done
  endif

  if (~file_test(config_fullpath, /regular)) then begin
    mg_log, 'config file not found', name=logger_name, /error
    status = 1L
    goto, done
  endif

  run = ucomp_run(date, 'verify', config_fullpath, /reprocess)
  if (not obj_valid(run)) then goto, done

  mg_log, name=logger_name, logger=logger
  logger->getProperty, filename=log_filename

  mg_log, 'checking %s', run.date, name=run.logger_name, /info

  ucomp_verify_check_files, run=run, status=check_files_status
  status or= 1L * check_files_status

  ucomp_verify_check_permissions, run=run, status=check_permissions_status
  status or= 2L * check_permissions_status

  ucomp_verify_check_logs, run=run, status=check_logs_status
  status or= 4L * check_logs_status

  ucomp_verify_check_collection_server, run=run, status=check_collection_server
  status or= 8L * check_collection_server

  ucomp_verify_check_archive_server, run=run, status=check_archive_server
  status or= 16L * check_archive_server

  done:

  if (status eq 0L) then begin
    mg_log, 'verification succeeded', name=logger_name, /info
  endif else begin
    mg_log, 'verification failed', name=logger_name, /error
  endelse

  if (obj_valid(run)) then obj_destroy, run
end


; main-level example program

logger_name = 'ucomp/verify'
cfile = 'ucomp.production.cfg'
config_filename = filepath(cfile, subdir=['..', 'config'], root=mg_src_root())

dates = ['20180708']
for d = 0L, n_elements(dates) - 1L do begin
  ucomp_verify, dates[d], config_filename

  if (d lt n_elements(dates) - 1L) then begin
    mg_log, name=logger_name, logger=logger
    logger->setProperty, format='%(time)s %(levelshortname)s: %(message)s'
    mg_log, '-----------------------------------', name=logger_name, /info
  endif
endfor

end
