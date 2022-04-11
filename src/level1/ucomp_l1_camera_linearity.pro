; docformat = 'rst'

;+
; Correct camera non-linearity.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, required, type="fltarr(nx, ny, n_pol, n_camera, n)"
;     extension data
;   headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_camera_linearity, file, primary_header, data, headers, $
                               run=run, status=status
  compile_opt strictarr

  status = 0L

  ; TODO: implement
end
