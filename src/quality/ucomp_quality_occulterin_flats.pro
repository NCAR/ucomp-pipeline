; docformat = 'rst'

;+
; Check that the occulter is not in for flats (and that the diffuser is in).
;
; :Returns:
;   1B for files with the occulter not "out" and a flat
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data, removes `n_cameras` dimension on output
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_quality_occulterin_flats, file, $
                                         primary_header, ext_data, ext_headers, $
                                         run=run
  compile_opt strictarr

  for e = 0L, n_elements(ext_headers) - 1L do begin
    is_flat = strtrim(ucomp_getpar(ext_headers[e], 'DATATYPE'), 2) eq 'flat'
    if (is_flat) then begin
      occulter_out = strtrim(ucomp_getpar(ext_headers[e], 'OCCULTR'), 2) eq 'out'
      diffuser_in = strtrim(ucomp_getpar(ext_headers[e], 'DIFFUSR'), 2) eq 'in'
      if (~occulter_out) then begin
        mg_log, 'rejecting flat file because occulter is not out for ext %d', $
                e + 1L, $
                name=run.logger_name, /warn
        return, 1UL
      endif
      if (~diffuser_in) then begin
        mg_log, 'rejecting flat file because diffuser is not in for ext %d', $
                e + 1L, $
                name=run.logger_name, /warn
        return, 1UL
      endif
    endif
  endfor

  return, 0UL
end