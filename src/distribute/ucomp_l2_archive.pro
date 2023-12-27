; docformat = 'rst'

;+
; Archive L2 files for given wave type on the archival system.
;
; :Params:
;   wave_region : in, required, type=string
;     wavelength type to distribute, i.e., '1074'
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l2_archive, wave_region, run=run
  compile_opt strictarr

  cd, current=original_dir

  if (~run->config(wave_region + '/send_to_archive')) then begin
    mg_log, 'skipping archiving %s nm L2 data', wave_region, $
            name=run.logger_name, /info
    goto, done
  endif

  l2_dir = filepath('level2', subdir=run.date, $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir)) then begin
    mg_log, 'L2 directory does not exist', name=run.logger_name, /warn
    goto, done
  endif
  cd, l2_dir

  version = ucomp_version()

  tarfile_basename = string(run.date, wave_region, version, $
                            format='(%"%s.ucomp.%s.l2.v%s.tar.gz")')
  tarlist_basename = string(run.date, wave_region, version, $
                            format='(%"%s.ucomp.%s.l2.v%s.tarlist")')
  tarfile = filepath(tarfile_basename, root=l2_dir)
  tarlist = filepath(tarlist_basename, root=l2_dir)

  ; skip sending L2 to archive if tarball already exists
  if (file_test(tarfile, /regular)) then begin
    mg_log, '%s nm level 2 tarball already exists, skipping', wave_region, $
            name=run.logger_name, /warn
    goto, done
  endif

  ; determine the types of files in tarball
  types = [string(wave_region, format='*.ucomp.%s.*.fts*'), $
           string(wave_region, format='*.ucomp.%s.*.mp4'), $
           string(wave_region, format='*.ucomp.%s.*.png'), $
           string(wave_region, format='*.ucomp.%s.*.gif')]
  n_files_by_type = lonarr(n_elements(types))
  for t = 0L, n_elements(types) - 1L do begin
    !null = file_search(types[t], count=n_files)
    n_files_by_type[t] = n_files
  endfor

  ; don't make tarball if no FITS files
  if (n_files_by_type[0] eq 0L) then begin
    mg_log, 'no %s nm level 2 FITS files to tar', wave_region, $
            name=run.logger_name, /warn
    goto, done
  endif

  for t = 0L, n_elements(types) - 1L do begin
    mg_log, 'found %s of type %s', $
            mg_plural(n_files_by_type[t], 'file', 'files'), $
            types[t], $
            name=run.logger_name, $
            /info
  endfor

  ; make glob based on what is present
  glob_indices = where(n_files_by_type gt 0L, n_glob_parts)
  glob = strjoin(types[glob_indices], ' ')

  ; make tarball
  tar_cmd = string(tarfile, glob, format='(%"tar cfz %s %s")')
  mg_log, 'creating tarfile %s...', file_basename(tarfile), $
          name=run.logger_name, /info
  spawn, tar_cmd, result, error_result, exit_status=status
  if (status ne 0L) then begin
    mg_log, 'problem tarring files with command: %s', tar_cmd, $
            name=run.logger_name, /error
    mg_log, '%s', strjoin(error_result, ' '), name=run.logger_name, /error
    goto, done
  endif
  ucomp_fix_permissions, tarfile, logger_name=run.logger_name

  ; make tarlist
  tarlist_cmd = string(tarfile, tarlist, format='(%"tar tfv %s > %s")')
  mg_log, 'creating tarlist %s...', file_basename(tarlist), name=run.logger_name, /info
  spawn, tarlist_cmd, result, error_result, exit_status=status
  if (status ne 0L) then begin
    mg_log, 'problem create tarlist file with command: %s', tarlist_cmd, $
            name=run.logger_name, /error
    mg_log, '%s', strjoin(error_result, ' '), name=run.logger_name, /error
    goto, done
  endif
  ucomp_fix_permissions, tarlist, logger_name=run.logger_name

  ; put link to level 2 tarball in the archive queue directory
  archive_gateway = run->config('results/archive_gateway')
  if (n_elements(archive_gateway) gt 0L) then begin
    ; create archive gateway directory if needed
    ucomp_mkdir, archive_gateway, logger_name=run.logger_name

    dst_tarfile = filepath(tarfile_basename, root=archive_gateway)

    ; remove old links to tarballs
    ; NOTE: need to test for dangling symlink separately because a link to a
    ; non-existent file will return 0 from FILE_TEST with just /SYMLINK
    if (file_test(dst_tarfile, /symlink) $
        || file_test(dst_tarfile, /dangling_symlink)) then begin
      mg_log, 'removing link to tarball in archive gateway', $
              name=run.logger_name, /warn
      file_delete, dst_tarfile
    endif

    file_link, tarfile, dst_tarfile
  endif else begin
    mg_log, 'no archive gateway set, not sending to archive', $
            name=run.logger_name, /warn
  endelse

  done:
  cd, original_dir
end
