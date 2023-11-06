; docformat = 'rst'

;+
; Placeholder to errors during level 1 processing. This test never fails
; directly, it will just be associated with a file if the level 1 processing
; fails later.
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
function ucomp_quality_processing, file, $
                                   primary_header, $
                                   ext_data, $
                                   ext_headers, $
                                   run=run
  compile_opt strictarr

  return, 0UL
end
