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
;   background_headers : in, required, type=list
;     extension headers of backgrounds as list of `strarr`
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
                            background_headers, $
                            run=run
  compile_opt strictarr

  limit = run->epoch('sgsloop_min')
  sgsloop = ucomp_getpar(primary_header, 'SGSLOOP')
  if (sgsloop lt limit) then begin
    mg_log, 'SGSLOOP %0.3f (< %0.3f)', sgsloop, limit, $
            name=run.logger_name, /warn
    return, 1B
  endif

  return, 0B
end
