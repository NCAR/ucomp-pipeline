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
pro ucomp_l1_alignment, file, primary_header, data, headers, run=run, status=status
  compile_opt strictarr

  status = 0L

  ; center images on occulter center

  n_pol_states = 4L
  dims = size(data, /dimensions)

  occulter_x = ucomp_getpar(primary_header, 'OCCLTR-X')
  occulter_y = ucomp_getpar(primary_header, 'OCCLTR-Y')

  occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
  radius_guess = ucomp_radius_guess(occulter_id, file.wave_region, run=run)
  dradius = 25.0

  post_angle_guess = run->epoch('post_angle_guess')
  post_angle_tolerance = run->epoch('post_angle_tolerance')

  rcam_center_guess = ucomp_occulter_guess(0, date, occulter_x, occulter_y, run=run)
  rcam_ext = file->get_occulter_finding_extension(0)
  if (n_elements(rcam_ext) eq 0L) then begin
    status = 1L
    goto, done
  endif
  rcam_index = rcam_ext - 1L
  mg_log, 'looking for occulter in RCAM in ext %d', rcam_ext, name=run.logger_name, /debug
  rcam_im = total(data[*, *, *, 0, rcam_index], 3) / n_pol_states
  file.rcam_geometry = ucomp_find_geometry(rcam_im, $
                                           xsize=run->epoch('nx'), $
                                           ysize=run->epoch('ny'), $
                                           center_guess=rcam_center_guess, $
                                           radius_guess=radius_guess, $
                                           dradius=dradius, $
                                           post_angle_guess=post_angle_guess, $
                                           post_angle_tolerance=post_angle_tolerance)
  tcam_center_guess = ucomp_occulter_guess(1, date, occulter_x, occulter_y, run=run)
  tcam_ext = file->get_occulter_finding_extension(1)
  if (n_elements(tcam_ext) eq 0L) then begin
    status = 1L
    goto, done
  endif
  tcam_index = tcam_ext - 1L
  mg_log, 'looking for occulter in TCAM in ext %d', tcam_ext, name=run.logger_name, /debug
  tcam_im = total(data[*, *, *, 1, tcam_index], 3) / n_pol_states
  file.tcam_geometry = ucomp_find_geometry(tcam_im, $
                                           xsize=run->epoch('nx'), $
                                           ysize=run->epoch('ny'), $
                                           center_guess=tcam_center_guess, $
                                           radius_guess=radius_guess, $
                                           dradius=dradius, $
                                           post_angle_guess=post_angle_guess, $
                                           post_angle_tolerance=post_angle_tolerance)

  p_angle = file.p_angle
  ucomp_addpar, primary_header, 'SOLAR_P0', p_angle, $
                comment='[deg] solar P angle applied (image has N up)', $
                format='(f9.3)'
  file.rcam_geometry.p_angle = p_angle
  file.tcam_geometry.p_angle = p_angle

  ; TODO: put geometry info, p_angle in the primary header after RCAMNUC

  for p = 0, n_pol_states - 1L do begin
    for e = 0L, file.n_extensions - 1L do begin
      data[*, *, p, 0, e] = ucomp_fshift(data[*, *, p, 0, e], $
                                         (dims[0] - 1.0) / 2.0 - file.rcam_geometry.occulter_center[0], $
                                         (dims[1] - 1.0) / 2.0 - file.rcam_geometry.occulter_center[1], $
                                         interp=1)

      data[*, *, p, 1, e] = ucomp_fshift(data[*, *, p, 1, e], $
                                         (dims[0] - 1.0) / 2.0 - file.tcam_geometry.occulter_center[0], $
                                         (dims[1] - 1.0) / 2.0 - file.tcam_geometry.occulter_center[1], $
                                         interp=1)

      data[*, *, p, 0, e] = rot(reverse(data[*, *, p, 0, e], 2), p_angle, /interp)
      data[*, *, p, 1, e] = rot(reverse(data[*, *, p, 1, e], 2), p_angle, /interp)
    endfor
  endfor

  done:
end
