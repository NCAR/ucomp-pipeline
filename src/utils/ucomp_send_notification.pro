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

  email = run->config('notifications/email')
  if (email eq '') then begin
    mg_log, 'no notification email set, not sending email', name='ucomp', /info
  endif else begin
    mg_log, 'sending notification email to %s', email, name='ucomp', /info

    ; add tag about pipeline and process at the end of body
    spawn, 'hostname', hostname, exit_status=status
    if (status ne 0) then hostname = 'unknown'

    body = list()

    ; TODO: add warnings/errors from logs
    ; TODO: add config file
    ; TODO: add quality histogram image

    body->add, string(mg_src_root(/filename), $
                      getenv('USER'), hostname, $
                      format='(%"Sent from %s (%s@%s)")')
    code_version = ucomp_version(revision=revision, branch=branch)
    body->add, string(code_version, revision, branch, $
                      format='(%"ucomp-pipeline %s (%s on %s)")')
    body->add, string(ucomp_sec2str(systime(/seconds) - run.t0), $
                      format='(%"Total runtime: %s")')

    subject = string(run.date, format='(%"UCoMP results for %s")')
    body_text = body->toArray()
    obj_destroy, body

    mg_send_mail, email, subject, body_text
  endelse
end
