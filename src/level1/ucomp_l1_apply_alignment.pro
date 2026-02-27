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
;   backgrounds : out, type="fltarr(nx, ny, n_pol_states, n_cameras, n_exts)"
;     background images
;   background_headers : in, required, type=list
;     extension headers for background images as list of `strarr`
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_apply_alignment, file, $
                              primary_header, $
                              data, headers, $
                              backgrounds, background_headers, $
                              run=run, status=status
  compile_opt strictarr

  status = 0L

  if (~run->config('centering/perform')) then begin
    mg_log, 'skipping centering images', name=run.logger_name, /warn
    goto, done
  endif

  use_bilinear = strlowcase(run->config('centering/interpolation_method')) eq 'bilinear'

  dims = size(data, /dimensions)
  n_pol_states = dims[2]

  rcam_geometry = file.rcam_geometry
  tcam_geometry = file.tcam_geometry

  ; center images on occulter center and rotate North up
  for e = 0L, file.n_extensions - 1L do begin
    for p = 0, n_pol_states - 1L do begin
      data[*, *, p, 0, e] = ucomp_center_image(data[*, *, p, 0, e], rcam_geometry, $
                                               bilinear=use_bilinear)
      data[*, *, p, 1, e] = ucomp_center_image(data[*, *, p, 1, e], tcam_geometry, $
                                               bilinear=use_bilinear)
      backgrounds[*, *, p, 0, e] = ucomp_center_image(backgrounds[*, *, p, 0, e], $
                                                      rcam_geometry, $
                                                      bilinear=use_bilinear)
      backgrounds[*, *, p, 1, e] = ucomp_center_image(backgrounds[*, *, p, 1, e],$
                                                      tcam_geometry, $
                                                      bilinear=use_bilinear)
    endfor
  endfor

  file.rotated = 1B

  ; apply geometry transformation to post angle found before the above
  ; transformation
  rcam_geometry.post_angle -= file.p_angle
  tcam_geometry.post_angle -= file.p_angle

  ucomp_addpar, primary_header, 'POST_ANG', $
                mean([rcam_geometry.post_angle, tcam_geometry.post_angle], /nan), $
                format='(F0.3)'

  after = 'CDELT2'
  ucomp_addpar, primary_header, 'CRPIX1', (dims[0] - 1.0) / 2.0 + 1.0, $
                comment='[pixel] occulter X center (index origin=1)', $
                format='(F0.1)', after=after
  ucomp_addpar, primary_header, 'CRVAL1', 0.0, $
                comment='[arcsec] occulter X sun center', $
                format='(F0.2)', after=after
  ucomp_addpar, primary_header, 'CTYPE1', 'HPLN-TAN', $
                comment='helioprojective west angle: solar X', before=after
  ucomp_addpar, primary_header, 'CUNIT1', 'arcsec', $
                comment='unit of CRVAL1', after=after

  ucomp_addpar, primary_header, 'CRPIX2', (dims[1] - 1.0) / 2.0 + 1.0, $
                comment='[pixel] occulter Y center (index origin=1)', $
                format='(F0.1)', after=after
  ucomp_addpar, primary_header, 'CRVAL2', 0.0, $
                comment='[arcsec] occulter Y sun center', $
                format='(F0.2)', after=after
  ucomp_addpar, primary_header, 'CTYPE2', 'HPLT-TAN', $
                comment='helioprojective north angle: solar Y', before=after
  ucomp_addpar, primary_header, 'CUNIT2', 'arcsec', $
                comment='unit of CRVAL2', after=after

  ucomp_addpar, primary_header, 'CTRINTPM', $
                use_bilinear ? 'bilinear' : 'cubic=-0.5', $
                comment='image centering interpolation method', $
                after='DISTORTF'

  done:
end
