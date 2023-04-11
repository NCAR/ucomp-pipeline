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
;   backgrounds : out, type="fltarr(nx, ny, n_cameras, n_exts)"
;     background images
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_apply_alignment, file, $
                              primary_header, data, headers, backgrounds, $
                              run=run, status=status
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

  ; center images on occulter center and rotate North up
  for e = 0L, file.n_extensions - 1L do begin
    for p = 0, n_pol_states - 1L do begin
      data[*, *, p, 0, e] = ucomp_center_image(data[*, *, p, 0, e], rcam_geometry)
      data[*, *, p, 1, e] = ucomp_center_image(data[*, *, p, 1, e], tcam_geometry)
    endfor
    backgrounds[*, *, 0, e] = ucomp_center_image(backgrounds[*, *, 0, e], rcam_geometry)
    backgrounds[*, *, 1, e] = ucomp_center_image(backgrounds[*, *, 1, e], tcam_geometry)
  endfor

  file.rotated = 1B

  ; apply geometry transformation to post angle found before the above
  ; transformation
  rcam_geometry.post_angle -= file.p_angle
  tcam_geometry.post_angle -= file.p_angle

  ucomp_addpar, primary_header, 'CRPIX1', (dims[0] - 1.0) / 2.0 + 1.0, $
                comment='[pixel] solar X center (index origin=1)', $
                format='(F0.1)'
  ucomp_addpar, primary_header, 'CRVAL1', 0.0, $
                comment='[arcsec] solar X sun center', $
                format='(F0.2)'
  ucomp_addpar, primary_header, 'CRUNIT1', 'arcsec', $
                comment='unit of CRVAL1'

  ucomp_addpar, primary_header, 'CRPIX2', (dims[1] - 1.0) / 2.0 + 1.0, $
                comment='[pixel] solar Y center (index origin=1)', $
                format='(F0.1)'
  ucomp_addpar, primary_header, 'CRVAL2', 0.0, $
                comment='[arcsec] solar Y sun center', $
                format='(F0.2)'
  ucomp_addpar, primary_header, 'CRUNIT2', 'arcsec', $
                comment='unit of CRVAL2'

  ucomp_addpar, primary_header, 'POST_ANG', $
                mean([rcam_geometry.post_angle, tcam_geometry.post_angle], /nan)

  done:
end
