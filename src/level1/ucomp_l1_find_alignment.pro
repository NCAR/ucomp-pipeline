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
pro ucomp_l1_find_alignment, file, primary_header, data, headers, run=run, status=status
  compile_opt strictarr

  status = 0L

  ; center images on occulter center

  dims = size(data, /dimensions)
  n_pol_states = dims[2]

  occulter_x = ucomp_getpar(primary_header, 'OCCLTR-X')
  occulter_y = ucomp_getpar(primary_header, 'OCCLTR-Y')

  occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
  radius_guess = ucomp_radius_guess(occulter_id, file.wave_region, run=run)
  dradius = 25.0

  post_angle_guess = run->epoch('post_angle_guess')
  post_angle_tolerance = run->epoch('post_angle_tolerance')

  rcam_center_guess = ucomp_occulter_guess(0, date, occulter_x, occulter_y, run=run)
  rcam_offband_indices = where(file.onband_indices eq 1, n_rcam_offband)

  mg_log, /check_math, name=run.logger_name, /warn
  rcam_im = mean(data[*, *, *, 0, rcam_offband_indices], dimension=3, /nan)
  while (size(rcam_im, /n_dimensions) gt 2L) do rcam_im = mean(rcam_im, dimension=3, /nan)
  ; if all elements of dimension 3 are NaNs then the above lines will produce
  ; an floating-point operand error (128)
  !null = check_math(mask=128)

  rcam_im = smooth(rcam_im, 2, /nan)
  file.rcam_geometry = ucomp_find_geometry(rcam_im, $
                                           xsize=run->epoch('nx'), $
                                           ysize=run->epoch('ny'), $
                                           center_guess=rcam_center_guess, $
                                           radius_guess=radius_guess, $
                                           dradius=dradius, $
                                           post_angle_guess=post_angle_guess, $
                                           post_angle_tolerance=post_angle_tolerance)

  tcam_center_guess = ucomp_occulter_guess(1, date, occulter_x, occulter_y, run=run)
  tcam_offband_indices = where(file.onband_indices eq 0, n_tcam_offband)

  mg_log, /check_math, name=run.logger_name, /warn
  tcam_im = mean(data[*, *, *, 1, tcam_offband_indices], dimension=3, /nan)
  while (size(tcam_im, /n_dimensions) gt 2L) do tcam_im = mean(tcam_im, dimension=3, /nan)
  ; if all elements of dimension 3 are NaNs then the above lines will produce
  ; an floating-point operand error (128)
  !null = check_math(mask=128)

  tcam_im = smooth(tcam_im, 2, /nan)
  file.tcam_geometry = ucomp_find_geometry(tcam_im, $
                                           xsize=run->epoch('nx'), $
                                           ysize=run->epoch('ny'), $
                                           center_guess=tcam_center_guess, $
                                           radius_guess=radius_guess, $
                                           dradius=dradius, $
                                           post_angle_guess=post_angle_guess, $
                                           post_angle_tolerance=post_angle_tolerance)

  ; ucomp_addpar, primary_header, 'IMAGESCL', float(image_scale), $
  ;               comment='[arcsec/pixel] image scale at focal plane'
  ; ucomp_addpar, primary_header, 'XOFFSET0', float(x_offset_0), $
  ;               comment='[px] occulter x-Offset 0'
  ; ucomp_addpar, primary_header, 'YOFFSET0', float(y_offset_0), $
  ;               comment='[px] occulter y-offest 0'
  ucomp_addpar, primary_header, 'RADIUS0', file.rcam_geometry.occulter_radius, $
                comment='[px] RCAM occulter radius'
  ucomp_addpar, primary_header, 'FITCHI0', file.rcam_geometry.occulter_chisq, $
                comment='[px] chi-squared for RCAM center fit'
  ; ucomp_addpar, primary_header, 'XOFFSET1', float(x_offset_1), $
  ;               comment='[px] occulter x-offset 1'
  ; ucomp_addpar, primary_header, 'YOFFSET1', float(y_offset_1), $
  ;               comment='[px] occulter y-offest 1'
  ucomp_addpar, primary_header, 'RADIUS1', file.tcam_geometry.occulter_radius, $
                comment='[px] TCAM cculter radius'
  ucomp_addpar, primary_header, 'FITCHI1', file.tcam_geometry.occulter_chisq, $
                comment='[px] chi-squared for TCAM center fit'
  ; ucomp_addpar, primary_header, 'MED_BACK', float(med_back), $
  ;               comment='[ppm] median of background'
  ; ucomp_addpar, primary_header, 'POST_ANG', file.rcam_geometry.post_ang, $
  ;               comment='[deg] post angle CCW from north'
  rcam_radius = file.rcam_geometry.occulter_radius
  tcam_radius = file.tcam_geometry.occulter_radius
  average_radius = (rcam_radius + tcam_radius) / 2.0
  ucomp_addpar, primary_header, 'RADIUS', average_radius, $
                comment='[px] occulter average radius'

  file->getProperty, p_angle=p_angle, b0=b0, semidiameter=semidiameter
  ucomp_addpar, primary_header, 'SOLAR_P0', p_angle, $
                comment='[deg] solar P angle applied (image has N up)', $
                format='(f9.3)'
  ucomp_addpar, primary_header, 'SOLAR_B', b0, $
                comment='[deg] solar B-Angle'
  ; TODO: how do I find this? I don't see a SECZ routine in SSW or Steve's code
  ; ucomp_addpar, primary_header, 'SECANT_Z', float(sec_z), $
  ;               comment='secant of the Zenith Distance'
  ucomp_addpar, primary_header, 'SEMIDIAM', semidiameter, $
                comment='[arcsec] solar semi-diameter'

  file.rcam_geometry.p_angle = p_angle
  file.tcam_geometry.p_angle = p_angle

  done:
end
