; docformat = 'rst'

;+
; Send notification when the pipeline crashes.
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_crash_notification, run=run
  compile_opt strictarr

  help, /last_message, output=help_output

  if (~obj_valid(run)) then begin
    if (n_elements(help_output) gt 1L && help_output[0] ne '') then begin
      print, transpose(help_output)
    endif
    goto, done
  endif

  address = run->config('notifications/email')
  if (run->config('notifications/send')) then begin
    if (n_elements(address) eq 0L) then begin
      mg_log, 'no address for crash notification', name=run.logger_name, /warn
    endif else begin
      mg_log, 'sending crash notification to %s', address, $
              name=run.logger_name, /info
    endelse
  endif else begin
    mg_log, 'not sending crash notification', name=run.logger_name, /info
    goto, done
  endelse

  body = [help_output, '']

  case 1 of
    run.mode eq 'realtime': begin
        rt_log_filename = filepath(run.date + '.ucomp.realtime.log', $
                                   root=run->config('logging/dir'))
        rt_errors = ucomp_log_filter(rt_log_filename, $
                                     /error, n_messages=n_rt_errors)
        name = 'real-time'
        body = [body, rt_log_filename + ':', '', rt_errors]
      end
    run.mode eq 'eod': begin
        eod_log_filename = filepath(run.date + '.ucomp.eod.log', $
                                    root=run->config('logging/dir'))
        eod_errors = ucomp_log_filter(eod_log_filename, $
                                      /error, n_messages=n_eod_errors)
        name = 'end-of-day'
        body = [body, eod_log_filename + ':', '', eod_errors]
      end
  endcase

  spawn, 'echo $(whoami)@$(hostname)', who, error_result, exit_status=status
  if (status eq 0L) then begin
    who = who[0]
  endif else begin
    who = 'unknown'
  endelse

  username = 'ucomp-pipeline@ucar.edu'

  credit = string(mg_src_root(/filename), who, format='(%"Sent from %s (%s)")')

  subject = string(name, run.date, run.config_flag, $
                   format='(%"UCoMP crash during %s processing for %s (%s)")')
  body = [body, '', credit]

  mg_send_mail, address, subject, body, from=username, $
                error=error, status_message=status_message
  if (error ne 0L) then begin
    mg_log, 'error sending crash notification ''%s'': %s', $
            subject, strjoin(status_message, ' '), $
            name=run.logger_name, /error
  endif

  done:
end
