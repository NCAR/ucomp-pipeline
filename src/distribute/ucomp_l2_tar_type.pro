; docformat = 'rst'

pro ucomp_l2_tar_type, name, wave_region, $
                       tarfile=tarfile, tarlist=tarlist, $
                       run=run
  compile_opt strictarr

  l2_dir = filepath('level2', subdir=run.date, $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir)) then begin
    mg_log, 'L2 directory does not exist', name=run.logger_name, /warn
    goto, done
  endif
  cd, l2_dir

  tarfile_basename = string(run.date, wave_region, name, $
                            format='(%"%s.ucomp.%s.l2.%s.tgz")')
  tarlist_basename = string(run.date, wave_region, name, $
                            format='(%"%s.ucomp.%s.l2.%s.tarlist")')
  tarfile = filepath(tarfile_basename, root=l2_dir)
  tarlist = filepath(tarlist_basename, root=l2_dir)

  glob = string(wave_region, name, format='*.ucomp.%s.l2.%s.fts')
  filenames = file_search(glob, count=n_files)

  if (n_files eq 0L) then begin
    mg_log, 'no %s nm %s files to tar', wave_region, name, $
            name=run.logger_name, /info
    goto, done
  endif

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

  done:
end
