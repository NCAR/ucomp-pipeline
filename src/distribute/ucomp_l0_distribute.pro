; docformat = 'rst'

;+
; Package and distribute level 0 products to the appropriate locations.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_l0_distribute, run=run
  compile_opt strictarr

  cd, current=original_dir

  if (~run->config('raw/distribute')) then begin
    mg_log, 'skipping distributing raw data', name=run.logger, /info
    goto, done
  endif

  l0_dir = filepath('', $
                    subdir=[run.date, 'level0'], $
                    root=run->config('processing/basedir'))
  cd, l0_dir

  ; make tarball of L0 data
  tarfile  = string(date, format='(%"%s.ucomp.l0.tgz")')
  tarlist  = string(date, format='(%"%s.ucomp.l0.tarlist")')

  if (file_test(tarfile, /regular)) then begin
    mg_log, 'tarfile already exists: %s', tarfile, name=run.logger_name, /warn
    goto, done
  endif

  tar_cmd = string(tarfile, $
                   format='(%"tar cf %s *.ucomp.fts* *.log")')
  mg_log, 'creating tarfile %s...', tarfile, name=run.logger_name, /info
  spawn, tar_cmd, result, error_result, exit_status=status
  if (status ne 0L) then begin
    mg_log, 'problem tarring files with command: %s', tar_cmd, $
            name=run.logger_name, /error
    mg_log, '%s', strjoin(error_result, ' '), name=run.logger_name, /error
    goto, done
  endif
  ucomp_fix_permissions, tarfile, logger_name=run.logger_name

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

  ; put link to L0 tarball in HPSS directory
  hpss_gateway = run->config('results/hpss_gateway')
  if (~run->config('eod/reprocess')) then begin
    if (hpss_gateway ne '') then begin
      ; create HPSS gateway directory if needed
      if (~file_test(hpss_gateway, /directory)) then begin
        file_mkdir, hpss_gateway
        file_chmod, hpss_gateway, '664'o
      endif

      ; remove old links to tarballs
      dst_tarfile = filepath(tarfile, root=hpss_gateway)
      ; need to test for dangling symlink separately because a link to a
      ; non-existent file will return 0 from FILE_TEST with just /SYMLINK
      if (file_test(dst_tarfile, /symlink) $
            || file_test(dst_tarfile, /dangling_symlink)) then begin
        mg_log, 'removing link to tarball in HPSS gateway', $
                name=run.logger_name, /warn
        file_delete, dst_tarfile
      endif

      file_link, filepath(tarfile, root=l0_dir), $
                 dst_tarfile
    endif else begin
      mg_log, 'no HPSS gateway set, not sending to HPSS', $
              name=run.logger_name, /warn
    endelse
  endif else begin
    mg_log, 'reprocessing, not sending to HPSS', name=run.logger_name, /info
  endelse

  done:
  cd, original_dir
end
