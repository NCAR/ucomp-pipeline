; docformat = 'rst'

;+
; Check whether the median background is too high.
;
; :Returns:
;   1B if the background is too high
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
function ucomp_gbu_max_background, file, $
                                   primary_header, $
                                   ext_data, $
                                   ext_headers, $
                                   backgrounds, $
                                   background_headers, $
                                   run=run
  compile_opt strictarr

  dt = string(file.ut_date, file.ut_time, format='%s.%s')
  max_background = run->line(file.wave_region, 'gbu_max_background', datetime=dt)
  return, file.median_background gt max_background
 end
