; docformat = 'rst'


;+
; Verify that the given filename is on the HPSS with correct permissions.
;
; :Params:
;   date : in, required, type=string
;     date in the form YYYYMMDD
;   filename : in, required, type=string
;     HPSS filename to check
;   filesize : in, required, type=integer
;     size of given file
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP run object
;-
pro ucomp_verify_hpss, date, filename, filesize, $
                      logger_name=logger_name, run=run
  compile_opt strictarr

  hsi_cmd = string(run.hsi, filename, format='(%"%s ls -l %s")')

  spawn, hsi_cmd, hsi_output, hsi_error_output, exit_status=exit_status
  if (exit_status ne 0L) then begin
    mg_log, 'problem connecting to HPSS with command: %s', hsi_cmd, $
            name=logger_name, /error
    mg_log, '%s', mg_strmerge(hsi_error_output), name=logger_name, /error
    status = 1
    goto, hpss_done
  endif

  ; for some reason, hsi puts its output in stderr
  matches = stregex(hsi_error_output, $
                    file_basename(filename, '.tgz') + '\.tgz', $
                    /boolean)
  ind = where(matches, count)
  if (count eq 0L) then begin
    mg_log, '%s tarball for %s not found on HPSS', $
            file_basename(filename), date, $
            name=logger_name, /error
    status = 1L
    goto, hpss_done
  endif else begin
    status_line = hsi_error_output[ind[0]]
    tokens = strsplit(status_line, /extract)

    ; check group ownership of tarball on HPSS
    if (tokens[3] ne 'cordyn') then begin
      mg_log, 'incorrect group owner %s for tarball on HPSS', $
              tokens[3], name=logger_name, /error
      status = 1L
      goto, hpss_done
    endif

    ; check protection of tarball on HPSS
    if (tokens[0] ne '-rw-rw-r--') then begin
      mg_log, 'incorrect permissions %s for tarball on HPSS', $
              tokens[0], name=logger_name, /error
      status = 1L
      goto, hpss_done
    endif

    ; check size of tarball on HPSS
    if (ulong64(tokens[4]) ne filesize) then begin
      mg_log, 'incorrect size %sB for tarball on HPSS', $
              mg_float2str(ulong64(tokens[4]), places_sep=','), $
              name=logger_name, /error
      status = 1L
      goto, hpss_done
    endif

    mg_log, 'verified %s tarball on HPSS', file_basename(filename), $
            name=logger_name, /info
    hpss_done:
  endelse
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
;-
pro kcor_verify, date, config_filename, status=status
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

  run = kcor_run(date, config_fullpath)

  mg_log, name=logger_name, logger=logger
  logger->setProperty, format='%(time)s %(levelshortname)s: %(message)s'

  ; TODO: implement verification

  done:

  if (status eq 0L) then begin
    mg_log, 'verification succeeded', name=logger_name, /info
  endif else begin
    mg_log, 'verification failed', name=logger_name, /error
  endelse

  obj_destroy, run
end


; main-level example program

logger_name = 'ucomp/verify'
cfile = 'ucomp.mgalloy.mlsodata.production.cfg'
config_filename = filepath(cfile, subdir=['..', 'config'], root=mg_src_root())

dates = ['20180708']
for d = 0L, n_elements(dates) - 1L do begin
  ucomp_verify, dates[d], config_filename=config_filename

  if (d lt n_elements(dates) - 1L) then begin
    mg_log, name=logger_name, logger=logger
    logger->setProperty, format='%(time)s %(levelshortname)s: %(message)s'
    mg_log, '-----------------------------------', name=logger_name, /info
  endif
endfor

end
