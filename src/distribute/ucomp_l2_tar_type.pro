; docformat = 'rst'

;+
; Make a tarball for a set of level 2 files.
;
; :Params:
;   name : in, required, type=string
;     name of type of files to add to the tarball
;   wave_region : in, required, type=string
;     wave region, i.e., '1074'
;
; :Keywords:
;   tarfile : out, optional, type=string
;     set to a named variable to retrieve the name of the created tarball
;   tarlist : out, optional, type=string
;     set to a named variable to retrieve the name of the created tarball list
;   filenames : out, optional, type=strarr
;     set to a named variable to retrieve the filenames of the files in the
;     tarball
;   n_files : out, optional, type=long
;     set to a named variable to retrieve the number of filenames found
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_l2_tar_type, name, wave_region, glob, $
                       tarfile=tarfile, tarlist=tarlist, $
                       filenames=filenames, $
                       n_files=n_files, $
                       run=run
  compile_opt strictarr

  n_files = 0L

  l2_dir = filepath('level2', subdir=run.date, $
                    root=run->config('processing/basedir'))
  if (~file_test(l2_dir)) then begin
    mg_log, 'L2 directory does not exist', name=run.logger_name, /warn
    goto, done
  endif
  cd, l2_dir

  tarfile_basename = string(run.date, wave_region, name, $
                            format='(%"%s.ucomp.%s.%s.tgz")')
  tarlist_basename = string(run.date, wave_region, name, $
                            format='(%"%s.ucomp.%s.%s.tarlist")')
  tarfile = filepath(tarfile_basename, root=l2_dir)
  tarlist = filepath(tarlist_basename, root=l2_dir)

  filenames = file_search(glob, count=n_files)

  if (n_files eq 0L) then begin
    mg_log, 'no %s nm %s files to tar', wave_region, name, $
            name=run.logger_name, /info
    goto, done
  endif

  ; make tarball
  tar_cmd = string(tarfile, glob, format='tar cfz %s %s')
  mg_log, 'creating %s...', file_basename(tarfile), $
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
  tarlist_cmd = string(tarfile, tarlist, format='tar tfv %s > %s')
  mg_log, 'creating %s...', file_basename(tarlist), name=run.logger_name, /info
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
