; docformat = 'rst'

;+
; Check that SGSLOOP is high enough.
;
; :Returns:
;   1B for files with too low SGSLOOP, 0B for good ones
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
;   backgrounds : out, type="fltarr(nx, ny, n_cameras, n_exts)"
;     background images
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_gbu_sgsloop, file, $
                            primary_header, $
                            ext_data, $
                            ext_headers, $
                            backgrounds, $
                            run=run
  compile_opt strictarr

  limit = run->epoch('sgsloop_min')
  for e = 0L, n_elements(ext_headers) - 1L do begin
    sgsloop = ucomp_getpar(ext_headers[e], 'SGSLOOP')
    if (sgsloop lt limit) then begin
      mg_log, 'SGSLOOP %0.3f (< %0.3f) in ext %d', sgsloop, limit, e + 1L, $
              name=run.logger_name, /warn
      return, 1B
    endif
  endfor

  return, 0B
end
