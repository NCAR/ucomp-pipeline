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
;   background_headers : in, required, type=undefined
;     not used in this step
;
; :Keywords:
;   run : in, required, type=object
;     `ucomp_run` object
;   status : out, optional, type=integer
;     set to a named variable to retrieve the status of the step; 0 for success
;-
pro ucomp_l1_find_alignment, file, $
                             primary_header, $
                             data, headers, $
                             backgrounds, background_headers, $
                             run=run, status=status
  compile_opt strictarr

  status = 0L

  ; center images on occulter center

  dims = size(data, /dimensions)
  n_pol_states = dims[2]
  if (run->config('centering/step_order') eq 'pre-gaincorrection') then begin
    datetime = strmid(file_basename(file.raw_filename), 0, 15)
    run->get_distortion, datetime=datetime, file.wave_region, $
                         dx0_c=dx0_c, $
                         dy0_c=dy0_c, $
                         dx1_c=dx1_c, $
                         dy1_c=dy1_c
  endif

  occulter_x = ucomp_getpar(primary_header, 'OCCLTR-X')
  occulter_y = ucomp_getpar(primary_header, 'OCCLTR-Y')

  occulter_id = ucomp_getpar(primary_header, 'OCCLTRID')
  radius_guess = ucomp_radius_guess(occulter_id, file.wave_region, run=run)
  mg_log, 'radius guess: %0.1f', radius_guess, name=run.logger_name, /debug
  dradius = run->epoch('dradius')

  post_angle_tolerance = run->epoch('post_angle_tolerance')
  post_angle_gap = run->epoch('post_angle_gap')

  rcam_post_angle_guess = run->epoch('rcam_post_angle_guess')

  rcam_offband_indices = where(file.onband_indices eq 1, n_rcam_offband)
  if (n_rcam_offband eq 0L) then begin
    mg_log, 'no offband RCAM images, skipping', name=run.logger_name, /warn
    status = 1L
    goto, done
  endif

  mg_log, /check_math, name=run.logger_name, /debug
  rcam_background = mean(reform(data[*, *, *, 0, rcam_offband_indices]), dimension=4, /nan)
  while (size(rcam_background, /n_dimensions) gt 3L) do rcam_background = mean(rcam_background, dimension=4, /nan)
  rcam_background = mean(rcam_background, dimension=3, /nan)

  rcam_center_guess = ucomp_occulter_guess(rcam_background, 0, date, $
                                           occulter_x, occulter_y, run=run)

  ; if all elements of dimension 3 are NaNs then the above lines will produce
  ; an floating-point operand error (128)
  !null = check_math(mask=128)
  if (run->config('centering/step_order') eq 'pre-gaincorrection') then begin
    rcam_background = reverse(ucomp_apply_distortion(reverse(rcam_background, $
                                                             1), $
                                                     dx0_c, dy0_c), $
                              2)
  endif
  smoothed_rcam_background = smooth(rcam_background, 3, /nan)
  file.rcam_geometry = ucomp_find_geometry(smoothed_rcam_background, $
                                           xsize=run->epoch('nx'), $
                                           ysize=run->epoch('ny'), $
                                           center_guess=rcam_center_guess, $
                                           radius_guess=radius_guess, $
                                           dradius=dradius, $
                                           post_angle_guess=rcam_post_angle_guess, $
                                           post_angle_gap=post_angle_gap, $
                                           post_angle_tolerance=post_angle_tolerance, $
                                           error=rcam_error, $
                                           post_err_msg=rcam_post_err_msg, $
                                           logger_name=run.logger_name)
  mg_log, 'RCAM geometry error: %d', rcam_error, name=run.logger_name, /debug
  if (strlen(rcam_post_err_msg) gt 0L) then begin
    mg_log, 'RCAM post error message: %s', rcam_post_err_msg, name=run.logger_name, /warn
  endif

  tcam_post_angle_guess = run->epoch('tcam_post_angle_guess')

  tcam_offband_indices = where(file.onband_indices eq 0, n_tcam_offband)
  if (n_tcam_offband eq 0L) then begin
    mg_log, 'no offband TCAM images, skipping', name=run.logger_name, /warn
    status = 1L
    goto, done
  endif

  mg_log, /check_math, name=run.logger_name, /debug
  tcam_background = mean(reform(data[*, *, *, 1, tcam_offband_indices]), dimension=4, /nan)
  while (size(tcam_background, /n_dimensions) gt 3L) do tcam_background = mean(tcam_background, dimension=4, /nan)
  tcam_background = mean(tcam_background, dimension=3, /nan)

  tcam_center_guess = ucomp_occulter_guess(tcam_background, 1, date, $
                                           occulter_x, occulter_y, run=run)

  ; if all elements of dimension 3 are NaNs then the above lines will produce
  ; an floating-point operand error (128)
  !null = check_math(mask=128)
  if (run->config('centering/step_order') eq 'pre-gaincorrection') then begin
    tcam_background = reverse(ucomp_apply_distortion(tcam_background, $
                                                     dx1_c, dy1_c), $
                              2)
  endif
  smoothed_tcam_background = smooth(tcam_background, 3, /nan)
  file.tcam_geometry = ucomp_find_geometry(smoothed_tcam_background, $
                                           xsize=run->epoch('nx'), $
                                           ysize=run->epoch('ny'), $
                                           center_guess=tcam_center_guess, $
                                           radius_guess=radius_guess, $
                                           dradius=dradius, $
                                           post_angle_guess=tcam_post_angle_guess, $
                                           post_angle_gap=post_angle_gap, $
                                           post_angle_tolerance=post_angle_tolerance, $
                                           error=tcam_error, $
                                           post_err_msg=tcam_post_err_msg, $
                                           logger_name=run.logger_name)
  mg_log, 'TCAM geometry error: %d', tcam_error, name=run.logger_name, /debug
  if (strlen(tcam_post_err_msg) gt 0L) then begin
    mg_log, 'TCAM post error message: %s', tcam_post_err_msg, name=run.logger_name, /warn
  endif

  rcam = file.rcam_geometry
  tcam = file.tcam_geometry

  radius_tolerance = 5.0   ; pixels
  if (abs(radius_guess - rcam.occulter_radius) gt radius_tolerance) then begin
    mg_log, 'radius guess %0.1f differs from found value %0.1f by more than %0.1f pixels', $
            radius_guess, rcam.occulter_radius, radius_tolerance, $
            name=run.logger_name, /warn
  endif
  if (abs(radius_guess - tcam.occulter_radius) gt radius_tolerance) then begin
    mg_log, 'radius guess %0.1f differs from found value %0.1f by more than %0.1f pixels', $
            radius_guess, tcam.occulter_radius, radius_tolerance, $
            name=run.logger_name, /warn
  endif

  if (run->config('centering/diagnostic_images')) then begin
    engineering_basedir = run->config('engineering/basedir')
    eng_dir = filepath('', $
                      subdir=ucomp_decompose_date(run.date), $
                      root=engineering_basedir)
    if (~file_test(eng_dir, /directory)) then begin
      ucomp_mkdir, eng_dir, logger_name=run.logger_name
    endif

    basename = file_basename(file.l1_basename, '.fts')
    camera_names = ['rcam', 'tcam']
    geometry = [rcam, tcam]

    for c = 0L, 1L do begin
      bkg_basename = string(basename, camera_names[c], format='%s.%s.bkg.gif')
      bkg_filename = filepath(bkg_basename, root=eng_dir)
      ucomp_write_bkg_annotation, c eq 0 $
                                    ? smoothed_rcam_background $
                                    : smoothed_tcam_background, $
                                  geometry[c], file.wave_region, bkg_filename, run=run
    endfor

    background_basename = string(basename, format='%s.bkg.sav')
    background_filename = filepath(background_basename, root=eng_dir)
    save, rcam_background, tcam_background, filename=background_filename
  endif

  after = 'WNDDIR'

  ucomp_addpar, primary_header, $
                'XOFFSET0', $
                rcam.occulter_center[0] - (rcam.xsize - 1.0) / 2.0, $
                comment='[pixels] RCAM occulter x-offset from CRPIX1', $
                format='(F0.3)', after=after
  ucomp_addpar, primary_header, $
                'YOFFSET0', $
                rcam.occulter_center[1] - (rcam.ysize - 1.0) / 2.0, $
                comment='[pixels] RCAM occulter y-offset from CRPIX2', $
                format='(F0.3)', after=after
  ucomp_addpar, primary_header, 'RADIUS0', rcam.occulter_radius, $
                comment='[pixels] RCAM occulter radius', $
                format='(F0.3)', after=after
  ucomp_addpar, primary_header, 'FITCHI0', rcam.occulter_chisq, $
                comment='[pixels] chi-squared for RCAM center fit', $
                format='(F0.6)', after=after

  ucomp_addpar, primary_header, $
                'XOFFSET1', $
                tcam.occulter_center[0] - (tcam.xsize - 1.0) / 2.0, $
                comment='[pixels] TCAM occulter x-offset from CRPIX1', $
                format='(F0.3)', after=after
  ucomp_addpar, primary_header, $
                'YOFFSET1', $
                tcam.occulter_center[1] - (tcam.ysize - 1.0) / 2.0, $
                comment='[pixels] TCAM occulter y-offset from CRPIX2', $
                format='(F0.3)', after=after
  ucomp_addpar, primary_header, 'RADIUS1', file.tcam_geometry.occulter_radius, $
                comment='[pixels] TCAM occulter radius', $
                format='(F0.3)', after=after
  ucomp_addpar, primary_header, 'FITCHI1', file.tcam_geometry.occulter_chisq, $
                comment='[pixels] chi-squared for TCAM center fit', $
                format='(F0.6)', after=after

  mg_log, 'RCAM post angle: %0.2f, TCAM post angle: %0.2f', $
          rcam.post_angle, tcam.post_angle, $
          name=run.logger_name, /debug
  ucomp_addpar, primary_header, 'POST_ANG', $
                file.post_angle, $
                comment='[deg] post angle CCW from north', $
                format='(F0.3)', after=after
  radius = mean([rcam.occulter_radius, tcam.occulter_radius], /nan)
  ucomp_addpar, primary_header, 'RADIUS', $
                radius, $
                comment='[pixels] occulter average radius', $
                format='(F0.3)', after=after

  image_scale = ucomp_compute_platescale(radius, occulter_id, file.wave_region, $
                                         run=run)
  file.image_scale = image_scale
  ucomp_addpar, primary_header, 'IMAGESCL', image_scale, $
                comment='[arcsec/pixels] image scale for this file', $
                format='(F0.4)', after=after

  ; determine eccentricity of cameras
  rcam_elliptical_geometry = ucomp_find_geometry(smoothed_rcam_background, $
                                                 xsize=run->epoch('nx'), $
                                                 ysize=run->epoch('ny'), $
                                                 center_guess=rcam_center_guess, $
                                                 radius_guess=radius_guess, $
                                                 dradius=dradius, $
                                                 post_angle_guess=post_angle_guess, $
                                                 post_angle_gap=post_angle_gap, $
                                                 post_angle_tolerance=post_angle_tolerance, $
                                                 /elliptical, $
                                                 eccentricity=rcam_eccentricity, $
                                                 ellipse_angle=rcam_ellipse_angle, $
                                                 logger_name=run.logger_name)
  rcam.eccentricity = rcam_eccentricity
  rcam.ellipse_angle = rcam_ellipse_angle
  obj_destroy, rcam_elliptical_geometry

  tcam_elliptical_geometry = ucomp_find_geometry(smoothed_tcam_background, $
                                                 xsize=run->epoch('nx'), $
                                                 ysize=run->epoch('ny'), $
                                                 center_guess=rcam_center_guess, $
                                                 radius_guess=radius_guess, $
                                                 dradius=dradius, $
                                                 post_angle_guess=post_angle_guess, $
                                                 post_angle_gap=post_angle_gap, $
                                                 post_angle_tolerance=post_angle_tolerance, $
                                                 /elliptical, $
                                                 eccentricity=tcam_eccentricity, $
                                                 ellipse_angle=tcam_ellipse_angle, $
                                                 logger_name=run.logger_name)
  tcam.eccentricity = tcam_eccentricity
  tcam.ellipse_angle = tcam_ellipse_angle
  obj_destroy, tcam_elliptical_geometry

  ucomp_addpar, primary_header, 'RCAMECC', rcam_eccentricity, $
                comment='occulter eccentricity in RCAM', $
                format='(F0.4)', after=after
  ucomp_addpar, primary_header, 'TCAMECC', tcam_eccentricity, $
                comment='occulter eccentricity in TCAM', $
                format='(F0.4)', after=after

  ucomp_addpar, primary_header, 'COMMENT', 'Occulter centering info', $
                before='XOFFSET0', /title
  ucomp_addpar, primary_header, 'COMMENT', $
                'X/YOFFSET define position w.r.t. distortion corrected L0 images', $
                before='XOFFSET0'

  after = 'OBJECT'
  ucomp_addpar, primary_header, 'WCSNAME', 'helioprojective-cartesian', $
                comment='World Coordinate System (WCS) name', $
                after=after
  ucomp_addpar, primary_header, $
                'CDELT1', $
                run->line(file.wave_region, 'plate_scale'), $
                comment='[arcsec/pixel] image X increment = platescale', $
                format='(f9.3)', after=after
  ucomp_addpar, primary_header, $
                'CDELT2', $
                run->line(file.wave_region, 'plate_scale'), $
                comment='[arcsec/pixel] image Y increment = platescale', $
                format='(f9.3)', after=after


  file->getProperty, semidiameter=semidiameter, $
                     distance_au=distance_au, $
                     p_angle=p_angle, $
                     b0=b0

  ucomp_addpar, primary_header, $
                'DSUN_OBS', $
                distance_au * run->epoch('au_to_meters'), $
                comment='[m] distance to the Sun from observer', $
                format='(f0.1)', $
                after=after
  ucomp_addpar, primary_header, $
                'HGLN_OBS', $
                0.0, $
                comment='[deg] Stonyhurst heliographic longitude', $
                format='(f0.3)', $
                after=after
  ucomp_addpar, primary_header, $
                'HGLT_OBS', $
                b0, $
                comment='[deg] Stonyhurst heliographic latitude', $
                format='(f0.3)', $
                after=after
  ucomp_addpar, primary_header, 'PC1_1', 1.0, $
                comment='coord transform matrix element (1, 1) WCS std.', $
                format='(F0.3)', after=after
  ucomp_addpar, primary_header, 'PC1_2', 0.0, $
                comment='coord transform matrix element (1, 2) WCS std.', $
                format='(F0.3)', after=after
  ucomp_addpar, primary_header, 'PC2_1', 0.0, $
                comment='coord transform matrix element (2, 1) WCS std.', $
                format='(F0.3)', after=after
  ucomp_addpar, primary_header, 'PC2_2', 1.0, $
                comment='coord transform matrix element (2, 2) WCS std.', $
                format='(F0.3)', after=after

  ucomp_addpar, primary_header, 'COMMENT', $
                'World Coordinate System (WCS) info', $
                before='WCSNAME', /title
  ucomp_addpar, primary_header, 'COMMENT', $
                'Ephemeris calculations done by sun.pro at time of DATE-OBS', $
                before='WCSNAME'

  after = 'CDELT2'

  ucomp_addpar, primary_header, 'SOLAR_P0', p_angle, $
                comment='[deg] solar P angle applied (image has N up)', $
                format='(f9.3)', after=after
  ucomp_addpar, primary_header, 'SOLAR_B0', b0, $
                comment='[deg] solar B-Angle', $
                format='(f9.3)', after=after

  sec_z = mlso_secant_z(file.julian_date, sidereal_time=sidereal_time)
  ucomp_addpar, primary_header, 'SECANT_Z', sec_z, $
                comment='secant of the Zenith Distance', $
                format='(F0.6)', after=after
  ucomp_addpar, primary_header, 'SID_TIME', sidereal_time, $
                comment='[day fraction] GMST sidereal time', $
                format='(F0.5)', after=after
  ucomp_addpar, primary_header, 'CAR_ROT', $
                long(file.carrington_rotation), $
                comment='Carrington Rotation Number', $
                after=after
  ucomp_addpar, primary_header, 'JUL_DATE', file.julian_date, $
                comment='[days] Julian date', $
                format='F0.9', after=after

  ucomp_addpar, primary_header, 'RSUN_OBS', semidiameter, $
                comment=string(distance_au * semidiameter, $
                               format='(%"[arcsec] solar radius using ref radius %0.2f\"")'), $
                format='(f8.2)', after=after
  ucomp_addpar, primary_header, 'R_SUN', $
                semidiameter / run->line(file.wave_region, 'plate_scale'), $
                comment='[pixel] solar radius', $
                format='(f9.2)', after=after
  ucomp_addpar, primary_header, 'RSUN_REF', $
                run->line(file.wave_region, 'solar_radius'), $
                comment=string(run->line(file.wave_region, 'solar_radius_wavelength'), $
                               format='[m] solar radius at %0.1f nm'), $
                format='(f11.1)', after=after

  ucomp_addpar, primary_header, 'COMMENT', 'Ephemeris info', $
                before='SOLAR_P0', /title
  ucomp_addpar, primary_header, 'COMMENT', $
                'Ephemeris calculations done by sun.pro at time of DATE-OBS', $
                before='SOLAR_P0'

  file.rcam_geometry.p_angle = p_angle
  file.tcam_geometry.p_angle = p_angle

  done:
end
