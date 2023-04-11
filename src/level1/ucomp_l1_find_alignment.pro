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
;   backgrounds : type=undefined
;     not used in this step
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_find_alignment, file, $
                             primary_header, data, headers, backgrounds, $
                             run=run, status=status
  compile_opt strictarr

  status = 0L

  ; center images on occulter center

  dims = size(data, /dimensions)
  n_pol_states = dims[2]

  occulter_x = ucomp_getpar(primary_header, 'OCCLTR-X')
  occulter_y = ucomp_getpar(primary_header, 'OCCLTR-Y')

  occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
  radius_guess = ucomp_radius_guess(occulter_id, file.wave_region, run=run)
  mg_log, 'radius guess: %0.1f', radius_guess, name=run.logger_name, /debug
  dradius = run->epoch('dradius')

  post_angle_guess = run->epoch('post_angle_guess')
  post_angle_tolerance = run->epoch('post_angle_tolerance')

  rcam_center_guess = ucomp_occulter_guess(0, date, occulter_x, occulter_y, run=run)
  rcam_offband_indices = where(file.onband_indices eq 1, n_rcam_offband)

  mg_log, /check_math, name=run.logger_name, /debug
  rcam_background = mean(reform(data[*, *, *, 0, rcam_offband_indices]), dimension=4, /nan)
  while (size(rcam_background, /n_dimensions) gt 3L) do rcam_background = mean(rcam_background, dimension=4, /nan)
  rcam_background = mean(rcam_background, dimension=3, /nan)

  ; if all elements of dimension 3 are NaNs then the above lines will produce
  ; an floating-point operand error (128)
  !null = check_math(mask=128)
  file.rcam_geometry = ucomp_find_geometry(smooth(rcam_background, 2, /nan), $
                                           xsize=run->epoch('nx'), $
                                           ysize=run->epoch('ny'), $
                                           center_guess=rcam_center_guess, $
                                           radius_guess=radius_guess, $
                                           dradius=dradius, $
                                           post_angle_guess=post_angle_guess, $
                                           post_angle_tolerance=post_angle_tolerance, $
                                           error=rcam_error, $
                                           post_err_msg=rcam_post_err_msg)
  mg_log, 'RCAM geometry error: %d', rcam_error, name=run.logger_name, /debug
  if (strlen(rcam_post_err_msg) gt 0L) then begin
    mg_log, 'RCAM post error message: %s', rcam_post_err_msg, name=run.logger_name, /warn
  endif

  tcam_center_guess = ucomp_occulter_guess(1, date, occulter_x, occulter_y, run=run)
  tcam_offband_indices = where(file.onband_indices eq 0, n_tcam_offband)

  mg_log, /check_math, name=run.logger_name, /debug
  tcam_background = mean(reform(data[*, *, *, 1, tcam_offband_indices]), dimension=4, /nan)
  while (size(tcam_background, /n_dimensions) gt 3L) do tcam_background = mean(tcam_background, dimension=4, /nan)
  tcam_background = mean(tcam_background, dimension=3, /nan)

  ; if all elements of dimension 3 are NaNs then the above lines will produce
  ; an floating-point operand error (128)
  !null = check_math(mask=128)
  file.tcam_geometry = ucomp_find_geometry(smooth(tcam_background, 2, /nan), $
                                           xsize=run->epoch('nx'), $
                                           ysize=run->epoch('ny'), $
                                           center_guess=tcam_center_guess, $
                                           radius_guess=radius_guess, $
                                           dradius=dradius, $
                                           post_angle_guess=post_angle_guess, $
                                           post_angle_tolerance=post_angle_tolerance, $
                                           error=tcam_error, $
                                           post_err_msg=tcam_post_err_msg)
  mg_log, 'TCAM geometry error: %d', tcam_error, name=run.logger_name, /debug
  if (strlen(tcam_post_err_msg) gt 0L) then begin
    mg_log, 'TCAM post error message: %s', tcam_post_err_msg, name=run.logger_name, /warn
  endif

  rcam = file.rcam_geometry
  tcam = file.tcam_geometry

  ; TODO: remove this correction when done verifying
  rcam.occulter_center += [0.010, 0.001]
  tcam.occulter_center += [0.014, -0.001]

  ucomp_addpar, primary_header, $
                'XOFFSET0', $
                rcam.occulter_center[0] - (rcam.xsize - 1.0) / 2.0, $
                comment='[px] RCAM occulter x-offset', $
                format='(F0.3)'
  ucomp_addpar, primary_header, $
                'YOFFSET0', $
                rcam.occulter_center[1] - (rcam.ysize - 1.0) / 2.0, $
                comment='[px] RCAM occulter y-offset', $
                format='(F0.3)'
  ucomp_addpar, primary_header, 'RADIUS0', rcam.occulter_radius, $
                comment='[px] RCAM occulter radius', $
                format='(F0.3)'
  ucomp_addpar, primary_header, 'FITCHI0', rcam.occulter_chisq, $
                comment='[px] chi-squared for RCAM center fit', $
                format='(F0.6)'

  ucomp_addpar, primary_header, $
                'XOFFSET1', $
                tcam.occulter_center[0] - (tcam.xsize - 1.0) / 2.0, $
                comment='[px] TCAM occulter x-offset', $
                format='(F0.3)'
  ucomp_addpar, primary_header, $
                'YOFFSET1', $
                tcam.occulter_center[1] - (tcam.ysize - 1.0) / 2.0, $
                comment='[px] TCAM occulter y-offset', $
                format='(F0.3)'
  ucomp_addpar, primary_header, 'RADIUS1', file.tcam_geometry.occulter_radius, $
                comment='[px] TCAM occulter radius', $
                format='(F0.3)'
  ucomp_addpar, primary_header, 'FITCHI1', file.tcam_geometry.occulter_chisq, $
                comment='[px] chi-squared for TCAM center fit', $
                format='(F0.6)'

  mg_log, 'RCAM post angle: %0.1f, TCAM post angle: %0.1f', $
          rcam.post_angle, tcam.post_angle, $
          name=run.logger_name, /debug
  ucomp_addpar, primary_header, 'POST_ANG', $
                mean([rcam.post_angle, tcam.post_angle], /nan), $
                comment='[deg] post angle CCW from north'
  radius = mean([rcam.occulter_radius, tcam.occulter_radius], /nan)
  ucomp_addpar, primary_header, 'RADIUS', $
                radius, $
                comment='[px] occulter average radius'

  image_scale = ucomp_compute_platescale(radius, occulter_id, file.wave_region, $
                                         run=run)
  ucomp_addpar, primary_header, 'IMAGESCL', image_scale, $
                comment='[arcsec/pixel] image scale at focal plane'

  ; determine eccentricity of cameras
  rcam_elliptical_geometry = ucomp_find_geometry(smooth(rcam_background, 2, /nan), $
                                                 xsize=run->epoch('nx'), $
                                                 ysize=run->epoch('ny'), $
                                                 center_guess=rcam_center_guess, $
                                                 radius_guess=radius_guess, $
                                                 dradius=dradius, $
                                                 post_angle_guess=post_angle_guess, $
                                                 post_angle_tolerance=post_angle_tolerance, $
                                                 /elliptical, $
                                                 eccentricity=rcam_eccentricity, $
                                                 ellipse_angle=rcam_ellipse_angle)
  rcam.eccentricity = rcam_eccentricity
  rcam.ellipse_angle = rcam_ellipse_angle
  obj_destroy, rcam_elliptical_geometry

  tcam_elliptical_geometry = ucomp_find_geometry(smooth(tcam_background, 2, /nan), $
                                                 xsize=run->epoch('nx'), $
                                                 ysize=run->epoch('ny'), $
                                                 center_guess=rcam_center_guess, $
                                                 radius_guess=radius_guess, $
                                                 dradius=dradius, $
                                                 post_angle_guess=post_angle_guess, $
                                                 post_angle_tolerance=post_angle_tolerance, $
                                                 /elliptical, $
                                                 eccentricity=tcam_eccentricity, $
                                                 ellipse_angle=tcam_ellipse_angle)
  tcam.eccentricity = tcam_eccentricity
  tcam.ellipse_angle = tcam_ellipse_angle
  obj_destroy, tcam_elliptical_geometry

  ucomp_addpar, primary_header, 'RCAMECC', rcam_eccentricity, $
                comment='occulter eccentricity in RCAM', format='(F0.6)'
  ucomp_addpar, primary_header, 'TCAMECC', tcam_eccentricity, $
                comment='occulter eccentricity in TCAM', format='(F0.6)'

  file->getProperty, semidiameter=semidiameter, $
                     distance_au=distance_au, $
                     p_angle=p_angle, $
                     b0=b0

  ucomp_addpar, primary_header, 'SOLAR_P0', p_angle, $
                comment='[deg] solar P angle applied (image has N up)', $
                format='(f9.3)'
  ucomp_addpar, primary_header, 'SOLAR_B', b0, $
                comment='[deg] solar B-Angle', $
                format='(f9.3)'

  sec_z = mlso_secant_z(file.julian_date, sidereal_time=sidereal_time)
  ucomp_addpar, primary_header, 'SECANT_Z', sec_z, $
                comment='secant of the Zenith Distance'
  ucomp_addpar, primary_header, 'SID_TIME', sidereal_time, $
                comment='[day fraction] GMST sidereal time'

  ucomp_addpar, primary_header, 'SEMIDIAM', semidiameter, $
                comment='[arcsec] solar semi-diameter', $
                format='(f9.2)'
  ucomp_addpar, primary_header, 'RSUN_OBS', semidiameter, $
                comment=string(distance_au * semidiameter, $
                               format='(%"[arcsec] solar radius using ref radius %0.2f\"")'), $
                format='(f8.2)'
  ucomp_addpar, primary_header, 'RSUN', $
                semidiameter, $
                comment='[arcsec] solar radius (old standard keyword)', $
                format='(f8.2)'
  ucomp_addpar, primary_header, 'R_SUN', $
                semidiameter / run->line(file.wave_region, 'plate_scale'), $
                comment='[pixel] solar radius', format='(f9.2)'

  ucomp_addpar, primary_header, $
                'CDELT1', $
                run->line(file.wave_region, 'plate_scale'), $
                comment='[arcsec/pixel] solar X increment = platescale', $
                format='(f9.4)'
  ucomp_addpar, primary_header, $
                'CDELT2', $
                run->line(file.wave_region, 'plate_scale'), $
                comment='[arcsec/pixel] solar Y increment = platescale', $
                format='(f9.4)'

  file.rcam_geometry.p_angle = p_angle
  file.tcam_geometry.p_angle = p_angle

  done:
end
