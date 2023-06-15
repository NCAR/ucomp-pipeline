; docformat = 'rst'

;+
; Check whether the Stokes V signal is too high.
;
; :Returns:
;   1B if the Stokes V signal is too high
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
function ucomp_gbu_vcrosstalk, file, $
                               primary_header, $
                               ext_data, $
                               ext_headers, $
                               backgrounds, $
                               background_headers, $
                               run=run
  compile_opt strictarr

  dt = string(file.ut_date, file.ut_time, format='%s.%s')
  max_v = run->line(file.wave_region, 'gbu_max_v_metric', datetime=dt)
  return, file.vcrosstalk_metric gt max_v
 end
