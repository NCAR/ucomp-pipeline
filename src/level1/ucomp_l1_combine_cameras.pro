; docformat = 'rst'

;+
; Combine cameras.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   ext_data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     extension data
;   ext_headers : in, required, type=list
;     extension headers as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_combine_cameras, file, primary_header, ext_data, ext_headers, $
                              run=run, status=status
  compile_opt strictarr

  status = 0L

  ; TODO: rotate cameras to same geometric configuration
  ; TODO: translate images to place center of occulter on center of image
  ; TODO: average on camera dimension
  ; ext_data = mean(ext_data, dimension=4, /preserve_type)

  mg_log, 'not implemented', name=run.logger, /warn
end
