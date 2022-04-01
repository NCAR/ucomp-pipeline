; docformat = 'rst'

;+
; Center the images on center of occulter in the correct orientation, i.e.,
; rotate them to be North up.
;
; :Params:
;   file : in, required, type=object
;     `ucomp_file` object
;   primary_header : in, required, type=strarr
;     primary header
;   data : in, out, required, type="fltarr(nx, ny, n_pol_states, n_cameras, nexts)"
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
pro ucomp_l1_apply_alignment, file, primary_header, data, headers, run=run, status=status
  compile_opt strictarr

  status = 0L

  if (~run->config('centering/perform')) then begin
    mg_log, 'skipping centering images', name=run.logger_name, /warn
    goto, done
  endif

  dims = size(data, /dimensions)
  n_pol_states = dims[2]

  rcam_geometry = file.rcam_geometry
  tcam_geometry = file.tcam_geometry

  ; center images on occulter center
  for p = 0, n_pol_states - 1L do begin
    for e = 0L, file.n_extensions - 1L do begin
      cam0_xshift = (dims[0] - 1.0) / 2.0 - rcam_geometry.occulter_center[0]
      cam0_yshift = (dims[1] - 1.0) / 2.0 - rcam_geometry.occulter_center[1]
      data[*, *, p, 0, e] = ucomp_fshift(data[*, *, p, 0, e], $
                                         cam0_xshift, $
                                         cam0_yshift, $
                                         interp=1)

      cam1_xshift = (dims[0] - 1.0) / 2.0 - tcam_geometry.occulter_center[0]
      cam1_yshift = (dims[1] - 1.0) / 2.0 - tcam_geometry.occulter_center[1]
      data[*, *, p, 1, e] = ucomp_fshift(data[*, *, p, 1, e], $
                                         cam1_xshift, $
                                         cam1_yshift, $
                                         interp=1)

      data[*, *, p, 0, e] = rot(reverse(data[*, *, p, 0, e], 2), file.p_angle, /interp, missing=0.0)
      data[*, *, p, 1, e] = rot(reverse(data[*, *, p, 1, e], 2), file.p_angle, /interp, missing=0.0)
    endfor
  endfor

  ; apply geometry transformation to post angle found before the above
  ; transformation
  rcam_geometry.post_angle = 180.0 - rcam_geometry.post_angle - file.p_angle
  tcam_geometry.post_angle = 180.0 - tcam_geometry.post_angle - file.p_angle

  done:
end
