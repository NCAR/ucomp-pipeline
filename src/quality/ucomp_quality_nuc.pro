; docformat = 'rst'

;+
; Check whether the NUC is consistent bewteen RCAM and TCAM.
;
; :Returns:
;   1B if any extensions don't have a matching datatype
;
; :Params:
;   file : in, required, type=object
;     UCoMP file object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_quality_nuc, file, $
                            primary_header, $
                            ext_data, $
                            ext_headers, $
                            run=run
  compile_opt strictarr

  rcam_nuc = ucomp_getpar(primary_header, 'RCAMNUC')
  tcam_nuc = ucomp_getpar(primary_header, 'TCAMNUC')
  if (rcam_nuc ne tcam_nuc) then begin
    msg = string(rcam_nuc, tcam_nuc, format='RCAM_NUC ''%s'' != TCAMNUC ''%s''')
    mg_log, msg, name=run.logger_name, /error
    run->send_alert, 'BAD_NUC_VALUE', msg
  endif

  rcam_index = ucomp_nuc2index(rcam_nuc, values=run->epoch('nuc_values'))
  if (rcam_index lt 0) then begin
    msg = string(rcam_nuc, format='RCAM_NUC ''%s'' not an accepted value')
    mg_log, msg, name=run.logger_name, /error
    run->send_alert, 'BAD_NUC_VALUE', msg
  endif

  tcam_index = ucomp_nuc2index(tcam_nuc, values=run->epoch('nuc_values'))
  if (tcam_index lt 0) then begin
    msg = string(tcam_nuc, format='TCAM_NUC ''%s'' not an accepted value')
    mg_log, msg, name=run.logger_name, /error
    run->send_alert, 'BAD_NUC_VALUE', msg
  endif

  return, (rcam_nuc ne tcam_nuc) || (rcam_index lt 0) || (tcam_index lt 0)
end
