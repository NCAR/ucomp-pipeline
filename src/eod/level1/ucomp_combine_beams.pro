; docformat = 'rst'

;+
; Combine beams.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, out, required, type="fltarr(nx, nx, n_pol_states, n_cameras, n_exts)"
;     extension data
;   headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;-
pro ucomp_combine_beams, file, primary_header, data, headers, run=run
  compile_opt strictarr

  ; TODO: implement for real, the below just averages over the `n_cameras`
  ; dimension to get rid of it
  data = mean(data, dimension=4)
end
