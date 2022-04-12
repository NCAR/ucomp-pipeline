; docformat = 'rst'

;+
; Check whether any extensions have a datatype that does not match the others.
;
; :Returns:
;   1B if any extensions don't have a matching datatype
;
; :Params:
;   file : in, required, type=object
;     UCoMP file object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_exts)"
;     extension data, removes `n_cameras` dimension on output
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_quality_datatype, file, $
                                 primary_header, $
                                 ext_data, $
                                 ext_headers, $
                                 run=run
  compile_opt strictarr

  datatype = ucomp_getpar(ext_headers[0], 'DATATYPE')
  for e = 1L, file.n_extensions - 1L do begin
    if (ucomp_getpar(ext_headers[e], 'DATATYPE') ne datatype) then return, 1
  endfor

  return, 0
end
