; docformat = 'rst'

;+
; Check whether all extensions have the same CONTIN value.
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
function ucomp_quality_contin, file, $
                               primary_header, $
                               ext_data, $
                               ext_headers, $
                               run=run
  compile_opt strictarr

  contin = ''
  for e = 1L, file.n_extensions - 1L do begin
    new_contin = sxpar(ext_headers[e], 'CONTIN')
    ext_datatype = ucomp_getpar(ext_headers[e], 'DATATYPE')
    if (contin eq '') then contin = new_contin else begin
      if (contin ne new_contin) then return, 1UL
    endelse
  endfor

  return, 0UL
end
