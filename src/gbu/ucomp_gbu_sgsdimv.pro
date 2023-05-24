; docformat = 'rst'

;+
; Check whether the SGSDIMS value is too low.
;
; :Returns:
;   1B if SGSDIMS is too low
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
;   backgrounds : out, type="fltarr(nx, ny, n_cameras, n_exts)"
;     background images
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_gbu_sgsdimv, file, $
                            primary_header, $
                            ext_data, $
                            ext_headers, $
                            backgrounds, $
                            run=run
  compile_opt strictarr

  dt = string(file.ut_date, file.ut_time, format='%s.%s')
  i0 = run->epoch('i0', datetime=dt)

  secz = sxpar(primary_header, 'SECANT_Z')

  voltage_threshold = 0.9 * i0 * exp(-0.05 * secz)

  sgs_dimv = fltarr(n_elements(ext_headers))
  for e = 0L, n_elements(ext_headers) - 1L do sgs_dimv = ucomp_getpar(ext_headers[e], 'SGSDIMV')

  return, mean(sgs_dimv, /nan) lt voltage_threshold
 end
