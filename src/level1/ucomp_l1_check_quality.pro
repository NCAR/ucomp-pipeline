; docformat = 'rst'

;+
; Check quality (process or not) for each file.
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
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_check_quality, file, primary_header, ext_data, ext_headers, $
                            run=run, status=status
  compile_opt strictarr

  ; TODO: check ext_data, set quality_bitmask
  quality_bitmask = 0UL

  files[f].quality_bitmask = quality_bitmask

  done:
end
