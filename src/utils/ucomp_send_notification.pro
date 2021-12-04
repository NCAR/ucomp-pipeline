; docformat = 'rst'

;+
; Send end-of-processing email notification.
;
; :Keywords:
;   run : in, required, type=object
;     UCoMP pipeline run object
;-
pro ucomp_send_notification, run=run
  compile_opt strictarr

  if (~run->config('notifications/send')) then begin
    mg_log, 'not sending notification', name=run.logger_name, /info
    goto, done
  endif

  email = run->config('notifications/email')
  if (n_elements(email) eq 0L) then begin
    mg_log, 'no notification email set, not sending email', $
            name=run.logger_name, /info
    goto, done
  endif

  mg_log, 'sending email to %s', email, name=run.logger_name, /info

  ; add tag about pipeline and process at the end of body
  spawn, 'hostname', hostname, exit_status=status
  if (status ne 0) then hostname = 'unknown'

  body = list()

  version = ucomp_version(revision=revision, branch=branch)
  body->add, string(version, revision, branch, $
                    format='(%"ucomp-pipeline %s (%s) [%s]")')
  body->add, ''

  all_files = run->get_files(count=n_all_files)

  ; add basic statistics on run
  body->add, '# Basic statistics'
  body->add, ''
  body->add, string(n_all_files, format='(%"number of raw files: %d")')
  body->add, ['', ''], /extract

  ; add warnings/errors from logs
  rt_log_filename = filepath(run.date + '.ucomp.realtime.log', $
                             root=run->config('logging/dir'))
  rt_errors = ucomp_log_filter(rt_log_filename, $
                               /error, n_messages=n_rt_errors)
  if (n_rt_errors eq 0L) then begin
    body-> add, '# No realtime errors in log'
  endif else begin
    body->add, string(n_rt_errors, format='(%"# Realtime errors in log (%d errors)")')
    body->add, ''
    body->add, rt_errors, /extract
    body->add, ''
    body->add, string(rt_log_filename, format='(%"see %s for details")')
  endelse
  body->add, ['', ''], /extract

  eod_log_filename = filepath(run.date + '.ucomp.eod.log', $
                              root=run->config('logging/dir'))
  eod_errors = ucomp_log_filter(eod_log_filename, $
                                /error, n_messages=n_eod_errors)
  if (n_eod_errors eq 0L) then begin
    body->add, '# No end-of-day errors in log'
  endif else begin
    body->add, string(n_eod_errors, format='(%"# End-of-day errors in log (%d errors)")')
    body->add, ''
    body->add, eod_errors, /extract
    body->add, ''
    body->add, string(eod_log_filename, format='(%"see %s for details")')
  endelse
  body->add, ['', ''], /extract

  ; add config file
  ; body->add, ['## Configuration file used', ''], /extract
  ; body->add, run.config_contents, /extract
  ; body->add, ['', ''], /extract

  wave_regions = run->config('options/wave_regions')
  for w = 0L, n_elements(wave_regions) - 1L do begin
    body->add, string(wave_regions[w], format='(%"# %s nm files")')
    body->add, ''

    files = run->get_files(data_type='sci', wave_region=wave_regions[w], $
                           count=n_files)
    if (n_files eq 0L) then begin
      body->add, string(wave_regions[w], format='(%"no %s nm files")')
      body->add, ['', ''], /extract
      continue
    endif

    gbu = ulonarr(n_files)
    for f = 0L, n_files - 1L do gbu[f] = files[f].gbu
    !null = where(gbu eq 0UL, n_good_files)
    body->add, string(n_good_files, format='(%"%d good files")')

    gbu_conditions = ucomp_gbu_conditions(wave_regions[w], run=run)
    for g = 0L, n_elements(gbu_conditions) - 1L do begin
      !null = where(gbu_conditions[g].mask and gbu, n_condition_files)
      if (n_condition_files gt 0L) then begin
        body->add, string(n_condition_files, gbu_conditions[g].description, $
                          format='(%"%d files with %s")')
      endif
    endfor
    body->add, ['', ''], /extract
  endfor

  body->add, string(mg_src_root(/filename), $
                    getenv('USER'), hostname, $
                    format='(%"Sent from %s (%s@%s)")')
  code_version = ucomp_version(revision=revision, branch=branch)
  body->add, string(code_version, revision, branch, $
                    format='(%"ucomp-pipeline %s (%s on %s)")')
  body->add, string(ucomp_sec2str(systime(/seconds) - run.t0), $
                    format='(%"Total runtime: %s")')

  subject = string(run.date, run.config_flag, format='(%"UCoMP results for %s (%s)")')
  body_text = body->toArray()
  obj_destroy, body

  ; add wave_region histogram image
  engineering_basedir = run->config('engineering/basedir')
  if (n_elements(engineering_basedir) gt 0L) then begin
    wave_region_histogram_filename = filepath(string(run.date, $
                                                     format='(%"%s.ucomp.wave_regions.png")'), $
                                              subdir=ucomp_decompose_date(run.date), $
                                              root=engineering_basedir)
    data_type_histogram_filename = filepath(string(run.date, $
                                                   format='(%"%s.ucomp.data_types.png")'), $
                                            subdir=ucomp_decompose_date(run.date), $
                                            root=engineering_basedir)
    attachments = [wave_region_histogram_filename, $
                   data_type_histogram_filename]
  endif

  mg_send_mail, email, subject, body_text, $
                from='ucomp-pipeline@ucar.edu', $
                attachments=attachments

  done:
end
