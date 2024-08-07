; docformat = 'rst'

;+
; Check whether all extensions wavelength match the file's FILTER value.
;
; :Returns:
;   1B if any extensions don't matching
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
function ucomp_quality_wave_region, file, $
                                    primary_header, $
                                    ext_data, $
                                    ext_headers, $
                                    run=run
  compile_opt strictarr

  wave_region = ucomp_getpar(primary_header, 'FILTER')

  for e = 0L, file.n_extensions - 1L do begin
    wavelength  = ucomp_getpar(ext_headers[e], 'WAVELNG')
    if (wave_region ne ucomp_wave_region(wavelength)) then return, 1UL
  endfor

  return, 0UL
end
