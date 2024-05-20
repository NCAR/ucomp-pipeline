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
function ucomp_quality_check_o1focus, file, $
                                      primary_header, $
                                      ext_data, $
                                      ext_headers, $
                                      run=run
  compile_opt strictarr

  ; O1FOCUS is reported to 3 decimal places
  threshold = 0.0001

  o1focus = ucomp_getpar(ext_headers[0], 'O1FOCUS')
  for e = 1L, file.n_extensions - 1L do begin
    ext_o1focus = ucomp_getpar(ext_headers[e], 'O1FOCUS')
    if (abs(ext_o1focus - o1focus) gt threshold) then begin
      return, 1UL
    endif
  endfor

  return, 0UL
end
