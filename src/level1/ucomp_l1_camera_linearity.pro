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
;   backgrounds : type=undefined
;     not used in this step
;   background_headers : in, required, type=undefined
;     not used in this step
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_camera_linearity, file, $
                               primary_header, $
                               data, headers, $
                               backgrounds, background_headers, $
                               run=run, status=status
  compile_opt strictarr

  status = 0L

  if (~run->config('cameras/apply_linearity')) then begin
    mg_log, 'skipping camera linearity correction', name=run.logger_name, /debug
    goto, done
  endif

  file.linearity_corrected = 1B

  dims = size(data, /dimensions)
  n_polstates = dims[2]
  n_cameras = dims[3]

  ; TODO: get linearity coefficients for cameras present
  rcam_coeffs = run->get_camera_linearity(camera, exptime)
  tcam_coeffs = run->get_camera_linearity(camera, exptime)

  for e = 0L, n_elements(headers) - 1L do begin
    for p = 0L, n_polstates - 1L do begin
      for c = 0L, n_cameras - 1L do begin
        cam = reform(data[*, *, p, c, e])
        cam = ucomp_apply_camera_linearity(cam, c eq 0 ? rcam_coeffs: tcam_coeffs)
        data[*, *, p, c, e] = cam
      endfor
    endfor
  endfor

  done:
  ucomp_addpar, primary_header, 'LIN_CRCT', boolean(file.linearity_corrected), $
                comment='camera linearity corrected', after='OBJECT'
end
