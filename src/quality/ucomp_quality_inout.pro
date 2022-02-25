; docformat = 'rst'

;+
; Check that the cover, occulter, diffuser, dark shutter, and cal optics  are
; either in or out.
;
; :Returns:
;   1B for files with not "in" or "out" values for COVER, OCCLTR, or DARKSHUT
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
function ucomp_quality_inout, file, primary_header, ext_data, ext_headers, $
                              run=run
  compile_opt strictarr

  status = 0UL
  keywords = ['COVER', 'OCCLTR', 'DARKSHUT', 'DIFFUSR', 'CALOPTIC']
  for e = 0L, n_elements(ext_headers) - 1L do begin
    for k = 0L, n_elements(keywords) - 1L do begin
      value = strlowcase(ucomp_getpar(ext_headers[e], keywords[k]))
    
      if (value ne 'in' && value ne 'out') then begin
        mg_log, '%s value %s not in or out', keywords[k], value, $
                name=run.logger_name, /warn
        status = 1UL
      endif
    endfor
  endfor

  return, status
end
