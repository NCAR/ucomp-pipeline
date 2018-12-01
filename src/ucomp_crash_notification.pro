; docformat = 'rst'

;+
; Send notification when the pipeline crashes.
;
; :Keywords:
;   run : in, required, type=object
;     `kcor_run` object
;-
pro ucomp_crash_notification, run=run
  compile_opt strictarr

  case 1 of
    run.mode eq 'realtime': begin
        rt_log_filename = filepath(run.date + '.ucomp.realtime.log', $
                                   root=run->config('logging/dir'))
        rt_errors = ucomp_filter_log(rt_log_filename, $
                                     /error, n_messages=n_rt_errors)
        name = 'real-time'
        body = [rt_log_filename, '', rt_errors]
      end
    run.mode eq 'eod': begin
        eod_log_filename = filepath(run.date + '.ucomp.eod.log', $
                                    root=run->config('logging/dir')
        eod_errors = ucomp_filter_log(eod_log_filename, $
                                      /error, n_messages=n_eod_errors)
        name = 'end-of-day'
        body = [eod_log_filename, '', eod_errors]
      end
  endcase

  address = run->config('notifications/email')
  if (address eq '') then begin
    mg_log, 'not sending crash notification', name=run.logger_name, /info
    return
  endif else begin
    mg_log, 'sending crash notification to %s', address, $
            name=run.logger_name, /info
  endelse

  spawn, 'echo $(whoami)@$(hostname)', who, error_result, exit_status=status
  if (status eq 0L) then begin
    who = who[0]
  endif else begin
    who = 'unknown'
  endelse

  credit = string(mg_src_root(/filename), who, format='(%"Sent from %s (%s)")')

  subject = string(name, run.date, $
                   format='(%"UCoMP crash during %s processing for %s")')
  body = [body, '', credit]

  mg_send_mail, address, subject, body, error=error
end
