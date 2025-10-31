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
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of check, `0L` for no
;     errors, `1L` for errors
;-
pro ucomp_verify_check_files, run=run, status=status, n_files=n_files
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
    mg_log, '%d files with bad dates', n_bad, name=run.logger_name, /error
    status = 1L
  endelse
end


;+
; Check the permissions on the files.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of check, `0L` for no
;     errors, `1L` for errors
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
    mg_log, '%d files with bad permissions', n_bad, name=run.logger_name, /error
    status = 1L
  endelse
end


;+
; Find the missing files.
;
; :Returns:
;   missing files listed in machine log, but not in the raw files as a `strarr`
;
; :Params:
;   raw_files : in, required, type=strarr
;     array of raw filenames in the raw directory
;   machine_log_filename : in, required, type=string
;     filename of machine log
;
; :Keywords:
;   extra_files : out, optional, type=strarr
;     files in `raw_files`, but not listed in machine log
;-
function ucomp_verify_missing, raw_files, machine_log_filename, $
                               extra_files=extra_files
  compile_opt strictarr

  extra_files = !null

  n_raw_files = n_elements(raw_files) eq 1 && raw_files[0] eq '' $
                  ? 0L $
                  : n_elements(raw_files)
  n_ml_lines = file_lines(machine_log_filename)

  ; this should not be able to happen
  if (n_ml_lines eq 0L) then return, !null

  ml_files = strarr(n_ml_lines)
  openr, lun, machine_log_filename, /get_lun
  readf, lun, ml_files
  free_lun, lun

  for i = 0L, n_ml_lines - 1L do ml_files[i] = (strsplit(ml_files[i], /extract))[0]

  if (n_raw_files eq 0L) then return, ml_files
  n_matches = mg_match(file_basename(raw_files), $
                       ml_files, $
                       a_matches=extra_file_indices, $
                       b_matches=missing_file_indices)
  missing_files = ml_files[mg_complement(missing_file_indices, n_ml_lines, /null)]
  extra_files = raw_files[mg_complement(extra_file_indices, n_raw_files, /null)]

  return, missing_files
end


;+
; Check collection server for files that are missing locally.
;
; :Returns:
;   returns number of missing files on collection server as a `long`
;
; :Params:
;   date : in, required, type=string
;     date to run on in the form "YYYYMMDD"
;   missing_files : in, required, type=strarr
;     array of basenames of the files that are missing locally
;   collection_server : in, required, type=string
;     collection server name
;   collection_basedir : in, required, type=string
;     collection server base directory
;   collection_ssh_key : in, optional, type=string
;     full path to SSH key to use to connect to collection server
;
; :Keywords:
;   logger_name : in, optional, type=string
;     name of logger to send log messages to
;   error : out, optional, type=long
;     set to a named variable to retrieve the error status, `0L` for no error,
;     `1L` for an error
;-
function ucomp_verify_check_missing, date, $
                                     missing_files, $
                                     collection_server, $
                                     collection_basedir, $
                                     collection_ssh_key, $
                                     logger_name=logger_name, $
                                     error=error
  compile_opt strictarr

  error = 0L

  ssh_options = ''
  if (n_elements(collection_ssh_key) gt 0L) then begin
    ssh_options += string(collection_ssh_key, format='(%"-i %s")')
  endif

  ssh_cmd = string(ssh_options, $
                   collection_server, $
                   collection_basedir, $
                   date, $
                   format='(%"ssh %s %s ls %s/%s")')

  n_on_server = 0L
  for f = 0L, n_elements(missing_files) - 1L do begin
    file_check_cmd = string(ssh_cmd, missing_files[f], format='(%"%s/%s")')
    spawn, file_check_cmd, $
           ssh_output, ssh_error, exit_status=ssh_status
    case ssh_status of
      0: n_on_server += 1L
      2:  ; not found on server, 2 is exit code of ls when it can't find file
      else: begin
          mg_log, 'error checking collection server (status %d)', ssh_status, $
                  name=logger_name, /error
          mg_log, 'ssh cmd: %s', file_check_cmd, name=logger_name, /error
          error = 1L
        end
    endcase
  endfor

  return, n_on_server
end


;+
; Check the machine log against the data:
;   - filenames in the machine log match those present in the incoming
;     directory
;   - file sizes in the machine log match those present in the incoming
;     directory
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the check, 0 for no
;     error, otherwise for an error
;   n_raw_files : out, optional, type=integer
;     set to a named variable to retrieve the number of raw files
;-
pro ucomp_verify_check_logs, run=run, status=status, $
                             n_raw_files=n_raw_files, $
                             machine_log_present=machine_log_present
  compile_opt strictarr

  n_raw_files = 0L
  status = 0L

  raw_basedir = run->config('raw/basedir')
  raw_dir = filepath(run.date, root=raw_basedir)
  raw_files = file_search(filepath('*.fts', root=raw_dir), count=n_raw_files)
  raw_basenames = file_basename(raw_files)
  machine_log_filename = filepath(string(run.date, format='(%"%s.ucomp.machine.log")'), $
                                  root=raw_dir)

  machine_log_present = file_test(machine_log_filename, /regular)
  if (~machine_log_present) then begin
    mg_log, 'machine log not present', name=run.logger_name, /warn
    status = 1L
    return
  endif

  n_ml_lines = file_lines(machine_log_filename)
  if (n_ml_lines eq 0L && n_raw_files ne 0L) then begin
    mg_log, 'machine log empty, but there are raw files', $
            name=run.logger_name, /error
    status = 1L
    return
  endif

  if (n_raw_files ne n_ml_lines) then begin
    mg_log, '%d raw files and %d files in machine log', $
            n_raw_files, n_ml_lines, $
            name=run.logger_name, /warn

    max_missing = run->config('verification/max_missing')
    if (n_raw_files lt (n_ml_lines - max_missing)) then begin
      status = 1L
      return
    endif

    missing_files = ucomp_verify_missing(raw_files, $
                                         machine_log_filename, $
                                         extra_files=extra_files)
    if (n_elements(extra_files) gt 0L) then begin
      mg_log, '%s in raw files, but not machine log', $
              mg_plural(n_elements(extra_files), 'extra file', 'extra files'), $
              name=run.logger_name, /warn
      for f = 0L, n_elements(extra_files) - 1L do begin
        mg_log, 'extra %s in raw', file_basename(extra_files[f]), $
                name=run.logger_name, /warn
      endfor
    endif

    collection_server = run->config('verification/collection_server')
    collection_basedir = run->config('verification/collection_basedir')
    if (n_elements(collection_server) eq 0L || n_elements(collection_basedir) eq 0L) then begin
      mg_log, 'cannot check collection server', name=run.logger_name, /warn
    endif else begin
      n_on_server = ucomp_verify_check_missing(run.date, $
                                               missing_files, $
                                               collection_server, $
                                               collection_basedir, $
                                               run->config('verification/ssh_key'), $
                                               logger_name=run.logger_name, $
                                               error=error)
      if (error ne 0L) then begin
        status = 1L
        return
      endif
    endelse

    n_missing_files = n_elements(missing_files)
    if (n_missing_files gt 0L) then begin
      for f = 0L, n_elements(missing_files) - 1L do begin
        mg_log, '%s missing, but present in machine log', $
                missing_files[f], $
                name=run.logger_name, /warn
      endfor
      if (n_elements(n_on_server) gt 0L) then begin
        if (n_on_server eq 0L) then begin
          mg_log, '%s not on collection server', $
                  mg_plural(n_missing_files, 'missing file', 'missing files'), $
                  name=run.logger_name, /warn
        endif else begin
          mg_log, '%d of %s on collection server', $
                  n_on_server, $
                  mg_plural(n_missing_files, 'missing file', 'missing files'), $
                  name=run.logger_name, /error
          status = 1L
          return
        endelse
      endif else begin
        mg_log, 'collection_server or collection_basedir not specified', $
                name=run.logger_name, /warn
      endelse
    endif
  endif

  n_bad = 0L
  if (n_raw_files eq 0L && n_ml_lines eq 0L) then goto, done

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

  for f = 0L, n_ml_lines - 1L do begin
    matching_index = where(ml_files[f] eq raw_basenames, n_matches)
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
                    name=run.logger_name, /error
          endif
        end
      n_matches gt 1: begin
          mg_log, 'multiple %s files', ml_files[f], name=run.logger_name, /error
          n_bad += 1L
          status = 1L
        end
    endcase
  endfor

  n_bad += n_elements(extra_files)

  done:
  if (n_bad eq 0L) then begin
    mg_log, 'raw files match machine log', name=run.logger_name, /info
  endif else begin
    mg_log, '%d raw files not matching machine log', n_bad, name=run.logger_name, /warn
  endelse
end


;+
; Check the filenames/sizes match those on the collection server.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of check, `0L` for no
;     errors, `1L` for errors
;-
pro ucomp_verify_check_collection_server, run=run, status=status
  compile_opt strictarr

  status = 0UL

  collection_server = run->config('verification/collection_server')
  if (n_elements(collection_server) eq 0L) then begin
    mg_log, 'no collection server specified', name=run.logger_name, /warn
    goto, done
  endif

  collection_basedir = run->config('verification/collection_basedir')
  if (n_elements(collection_basedir) eq 0L) then begin
    mg_log, 'no collection basedir specified', name=run.logger_name, /warn
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
  ; TODO: this is not actually the way to check if there are missing or extra
  ; files, there could be extra AND missing files that balance each other
  if (n_raw_files ne n_log_lines) then begin
    max_missing = run->config('verification/max_missing')
    mg_log, '# raw files on collection server (%d) does not match # lines in machine log (%d)', $
            n_raw_files, n_log_lines, $
            name=run.logger_name, /warn
    if (n_raw_files le (n_log_lines - max_missing)) then begin
      mg_log, 'too many missing files (%d)', n_log_lines - n_raw_files, $
              name=run.logger_name, /error
      status or= 1UL
    endif else if (n_raw_files lt n_log_lines) then begin
      mg_log, 'missing %s, less than the max allowable (%s)', $
              mg_plural(n_log_lines - n_raw_files, 'file', 'files'), $
              mg_plural(max_missing, 'file', 'files'), $
              name=run.logger_name, /info
    endif
    if (n_raw_files gt n_log_lines) then begin
      mg_log, '%d extra files not in log', n_raw_files - n_log_lines, $
              name=run.logger_name, /warn
    endif
    goto, done
  endif

  mg_log, 'number of raw files on collection server matches machine log', $
          name=run.logger_name, /info

  done:
end


;+
; Check the filenames/sizes of the tarballs match those on the archive server.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=long
;     set to a named variable to retrieve the status of check, `0L` for no
;     errors, `1L` for errors
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
  status or= 1UL * ucomp_verify_check_remote_file(l0_basename, $
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
;     -1 for missing data, and anything else indicates a problem
;   log_filename : out, optional, type=string
;     set to a named variable to retrieve the filename of the log file for the
;     date
;   mode : in, optional, type=string, default=verify
;     logger mode
;-
pro ucomp_verify, date, config_filename, $
                  status=status, $
                  log_filename=log_filename, $
                  mode=mode
  compile_opt strictarr

  status = 0L
  _mode = mg_default(mode, 'verify')
  logger_name = 'ucomp/' + _mode

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

  run = ucomp_run(date, _mode, config_fullpath, /reprocess)
  if (not obj_valid(run)) then goto, done

  mg_log, name=logger_name, logger=logger
  logger->getProperty, filename=log_filename

  mg_log, 'checking %s', run.date, name=run.logger_name, /info

  ucomp_verify_check_files, run=run, status=check_files_status, $
                            n_files=n_raw_files
  status or= 1L * check_files_status

  ucomp_verify_check_permissions, run=run, status=check_permissions_status
  status or= 2L * check_permissions_status

  ucomp_verify_check_logs, run=run, status=check_logs_status, $
                           n_raw_files=n_raw_files_in_logs, $
                           machine_log_present=machine_log_present
  status or= 4L * check_logs_status

  ucomp_verify_check_collection_server, run=run, status=check_collection_server
  status or= 8L * check_collection_server

  if (n_raw_files_in_logs gt 0L) then begin
    ucomp_verify_check_archive_server, run=run, status=check_archive_server
    status or= 16L * check_archive_server
  endif else begin
    mg_log, 'skipping archive server check because no raw files', $
            name=run.logger_name, /info
  endelse

  if (n_raw_files eq 0L && ~machine_log_present) then begin
    status = -1L
  endif

  done:

  if (status eq 0L) then begin
    mg_log, 'verification succeeded', name=logger_name, /info
  endif else begin
    if (status lt 0L) then begin
      mg_log, 'no data for this date', name=logger_name, /warn
    endif else begin
      mg_log, 'verification failed (%d)', status, name=logger_name, /error
    endelse
  endelse

  if (obj_valid(run)) then obj_destroy, run
end


; main-level example program

date = '20240826'
config_basename = 'ucomp.production.cfg'
config_filename = filepath(config_basename, $
                           subdir=['..', '..', '..', 'ucomp-config'], $
                           root=mg_src_root())

ucomp_verify, date, config_filename, $
              status=status, $
              log_filename=log_filename, $
              mode=mode

end
