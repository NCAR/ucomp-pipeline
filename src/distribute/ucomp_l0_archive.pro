; docformat = 'rst'

;+
; Archive L0 files on the HPSS.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l0_archive, run=run
  compile_opt strictarr

  cd, current=original_dir

  l0_dir = filepath(run.date, root=run->config('raw/basedir'))
  if (~file_test(l0_dir)) then begin
    mg_log, 'raw directory does not exist', name=run.logger_name, /error
    goto, done
  endif
  cd, l0_dir

  ; make tarball of L0 data
  tarfile  = string(run.date, format='(%"%s.ucomp.l0.tgz")')
  tarlist  = string(run.date, format='(%"%s.ucomp.l0.tarlist")')

  ; skip sending L0 to HPSS if tarball already exists
  if (file_test(tarfile, /regular)) then begin
    mg_log, 'L0 tarball already exists, skipping', name=run.logger_name, /warn
    goto, done
  endif

  ; determine the types of files in tarball
  types = ['*.ucomp.fts*', $
           '*.log']
  n_files_by_type = lonarr(n_elements(types))
  for t = 0L, n_elements(types) - 1L do begin
    !null = file_search(types[t], count=n_files)
    n_files_by_type[t] = n_files
  endfor

  glob_indices = where(n_files_by_type gt 0L, n_glob_parts)
  if (n_glob_parts eq 0L) then begin
    mg_log, 'no files to tar', name=run.logger_name, /warn
    goto, done
  endif
  glob = strjoin(types[glob_indices], ' ')

  ; make tarball
  tar_cmd = string(tarfile, $
                   glob, $
                   format='(%"tar cf %s %s")')
  mg_log, 'creating tarfile %s...', tarfile, name=run.logger_name, /info
  spawn, tar_cmd, result, error_result, exit_status=status
  if (status ne 0L) then begin
    mg_log, 'problem tarring files with command: %s', tar_cmd, $
            name=run.logger_name, /error
    mg_log, '%s', strjoin(error_result, ' '), name=run.logger_name, /error
    goto, done
  endif
  ucomp_fix_permissions, tarfile, logger_name=run.logger_name

  ; make tarlist
  tarlist_cmd = string(tarfile, tarlist, $
                       format='(%"tar tfv %s > %s")')
  mg_log, 'creating tarlist %s...', tarlist, name=run.logger_name, /info
  spawn, tarlist_cmd, result, error_result, exit_status=status
  if (status ne 0L) then begin
    mg_log, 'problem create tarlist file with command: %s', tarlist_cmd, $
            name=run.logger_name, /error
    mg_log, '%s', strjoin(error_result, ' '), name=run.logger_name, /error
    goto, done
  endif
  ucomp_fix_permissions, tarlist, logger_name=run.logger_name

  ; put link to L0 tarball in the archive directory
  archive_gateway = run->config('results/archive_gateway')
  if (run->config('raw/send_to_archive')) then begin
    if (n_elements(archive_gateway) gt 0L) then begin
      ; create archive gateway directory if needed
      ucomp_mkdir, archive_gateway, logger_name=run.logger_name

      dst_tarfile = filepath(tarfile, root=archive_gateway)

      ; remove old links to tarballs
      ; NOTE: need to test for dangling symlink separately because a link to a
      ; non-existent file will return 0 from FILE_TEST with just /SYMLINK
      if (file_test(dst_tarfile, /symlink) $
          || file_test(dst_tarfile, /dangling_symlink)) then begin
        mg_log, 'removing link to tarball in archive gateway', $
                name=run.logger_name, /warn
        file_delete, dst_tarfile
      endif

      file_link, filepath(tarfile, root=l0_dir), $
                 dst_tarfile
    endif else begin
      mg_log, 'no archive gateway set, not sending to archive', $
              name=run.logger_name, /warn
    endelse
  endif else begin
    mg_log, 'skipping sending to archive', name=run.logger_name, /info
  endelse

  done:
  cd, original_dir
end