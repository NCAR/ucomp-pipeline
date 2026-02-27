; docformat = 'rst'

;+
; Ran after all attempts to run `ucomp_eod_wrapper` to check if there is any
; data.
;
; :Params:
;   date : in, required, type=string
;     date to process in the form "YYYYMMDD"
;   config_filename : in, required, type=string
;     filename for configuration file to use
;-
pro ucomp_eod_check_wrapper, date, config_filename
  compile_opt strictarr

  ; initialize performance metrics

  orig_except = !except
  !except = 0

  mode = 'eod'
  logger_name = string(mode, format='(%"ucomp/%s")')

  ; error handler
  catch, error
  if (error ne 0) then begin
    catch, /cancel
    mg_log, /last_error, name=logger_name, /critical
    ucomp_crash_notification, run=run
    goto, done
  endif

  if (n_params() ne 2) then begin
    mg_log, 'incorrect number of arguments', name=logger_name, /critical
    goto, done
  endif

  config_fullpath = file_expand_path(config_filename)
  if (~file_test(config_fullpath, /regular)) then begin
    mg_log, 'config file %s not found', config_fullpath, $
            name=logger_name, /critical
    goto, done
  endif

  ;== initialize

  ; create run object
  run = ucomp_run(date, mode, config_fullpath)
  if (~obj_valid(run)) then begin
    mg_log, 'cannot create run object', name=logger_name, /critical
    goto, done
  endif
  run.t0 = t0
  run->start_profiler

  ; log starting up pipeline with versions
  mg_log, '------------------------------', name=run.logger_name, /info
  version = ucomp_version(revision=revision, branch=branch)
  mg_log, 'ucomp-pipeline %s (%s) [%s]', version, revision, branch, $
          name=run.logger_name, /info
  mg_log, 'using IDL %s on %s (%s)', $
          !version.release, !version.os_name, mg_hostname(), $
          name=run.logger_name, /debug

  machinelog_valid = ucomp_validate_machinelog(present=machinelog_present, $
                                               n_missing_files=n_missing_files, $
                                               n_extra_files=n_extra_files, $
                                               n_files=n_files, $
                                               run=run)
  if (~machinelog_present || ~machinelog_valid || (n_files eq 0L)) then begin
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

    body->add, string(n_files, format='(%"# of files: %d")')
    body->add, string(n_missing_files, format='(%"# of missing files: %d")')
    body->add, string(n_extra_files, format='(%"# of extra files: %d")')

    body->add, ''

    body->add, string(mg_src_root(/filename), $
                      getenv('USER'), hostname, $
                      format='(%"Sent from %s (%s@%s)")')
    code_version = ucomp_version(revision=revision, branch=branch)
    body->add, string(code_version, revision, branch, $
                      format='(%"ucomp-pipeline %s (%s on %s)")')

    body_text = body->toArray()
    obj_destroy, body

    case 1 of
      ~machinelog_present: msg = 'machine log not present'
      n_files eq 0L: msg = 'no raw files'
      n_missing_files gt 0L: msg = string(n_missing_files, format='(%"%d missing files")')
      n_extra_files gt 0L: msg = string(n_extra_files, format='(%"%d extra files")')
      else: msg = 'unknown error'
    endcase

    subject = string(run.date, run.config_flag, msg, $
                     format='(%"UCoMP end-of-day check for %s (%s): %s")')
    mg_send_mail, email, subject, body_text, $
                  from='$(whoami)@ucar.edu', $
                  error=error, status_message=status_message
    if (error ne 0L) then begin
      mg_log, 'error sending EOD otification ''%s'': %s', $
              subject, strjoin(status_message, ' '), $
              name=run.logger_name, /error
    endif
  endif else begin
    mg_log, 'machine log and correct data present', name=run.logger_name, /info
  endelse

  ;== cleanup and quit
  done:

  if (obj_valid(run)) then obj_destroy, run
  mg_log, /quit

  !except = orig_except
end
