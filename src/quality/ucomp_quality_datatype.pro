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
;   ext_data : in, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data
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
    ext_datatype = ucomp_getpar(ext_headers[e], 'DATATYPE')
    if (ext_datatype ne datatype) then begin
      ; allow flat and cal to be in mixed in a file, but any other
      ; combination is a problem
      if (ext_datatype eq 'cal' && datatype  eq 'flat') then continue
      if (ext_datatype eq 'flat' && datatype  eq 'cal') then continue
      return, 1UL
    endif
  endfor

  return, 0UL
end
