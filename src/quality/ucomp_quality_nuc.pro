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

  rcam_index = ucomp_nuc2index(rcam_nuc, values=run->epoch('nuc_values'))
  tcam_index = ucomp_nuc2index(tcam_nuc, values=run->epoch('nuc_values'))

  return, (rcam_nuc ne tcam_nuc) || (rcam_index lt 0) || (tcam_index lt 0)
end
