; docformat = 'rst'

;+
; Check whether the difference of the image's background from the median value
; for the wave region is above the threshold.
;
; :Returns:
;   1B if the difference is too high
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
;   background_headers : in, required, type=list
;     extension headers of backgrounds as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
function ucomp_gbu_background_diff, file, $
                                    primary_header, $
                                    ext_data, $
                                    ext_headers, $
                                    backgrounds, $
                                    background_headers, $
                                    run=run
  compile_opt strictarr

  ; this is just a placeholder so that this condition is placed in the list of
  ; conditions in the GBU file; the real work is done in the routine
  ; ucomp_l1_check_gbu_median_diff
  return, 0UL
end
