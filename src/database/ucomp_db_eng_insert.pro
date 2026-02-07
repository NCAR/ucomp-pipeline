; docformat = 'rst'

;+
; Insert an array of L0 FITS files into the ucomp_eng database table.
;
; :Params:
;   l0_files : in, required, type=strarr
;     array of `UCOMP_FILE` objects
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   sw_index : in, required, type=integer
;     index into the ucomp_sw database table
;   db : in, optional, type=object
;     `UCOMPdbMySQL` database connection to use
;
; :Keywords:
;   logger_name : in, required, type=string
;     logger name to use for logging, i.e., "ucomp/rt", "ucomp/eod", etc.
;-
pro ucomp_db_eng_insert, l0_files, obsday_index, sw_index, db, logger_name=logger_name
  compile_opt strictarr

  n_files = n_elements(l0_files)
  mg_log, 'inserting %d files into ucomp_eng', n_files, name=logger_name, /info

  ; get index for OK quality data files
  q = 'select * from ucomp_quality where quality=''OK'''
  quality_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  quality_index = quality_results.quality_id

  ; get index for raw (level 0) data files
  q = 'select * from ucomp_level where level=''L0'''
  level_results = db->query(q, status=status)
  if (status ne 0L) then goto, done
  level_index = level_results.level_id

  fields = [{name: 'file_name', type: '''%s'''}, $
            {name: 'date_obs', type: '''%s'''}, $
            {name: 'obsday_id', type: '%d'}, $
            {name: 'obsday_hours', type: '%f'}, $
            {name: 'level_id', type: '%d'}, $

            {name: 'focus', type: '%f'}, $
            {name: 'o1focus', type: '%s'}, $

            {name: 'obs_id', type: '''%s'''}, $
            {name: 'obs_id_version', type: '''%s'''}, $
            {name: 'obs_plan', type: '''%s'''}, $
            {name: 'obs_plan_version', type: '''%s'''}, $

            {name: 'cover', type: '%d'}, $
            {name: 'darkshutter', type: '%d'}, $
            {name: 'opal', type: '%d'}, $
            {name: 'polangle', type: '%f'}, $
            {name: 'retangle', type: '%f'}, $
            {name: 'caloptic', type: '%d'}, $

            {name: 'rcam_xcenter', type: '%s'}, $
            {name: 'rcam_ycenter', type: '%s'}, $
            {name: 'rcam_radius', type: '%s'}, $
            {name: 'rcam_occulter_chisq', type: '%s'}, $
            {name: 'tcam_xcenter', type: '%s'}, $
            {name: 'tcam_ycenter', type: '%s'}, $
            {name: 'tcam_radius', type: '%s'}, $
            {name: 'tcam_occulter_chisq', type: '%s'}, $

            {name: 'radius_guess', type: '%s'}, $

            {name: 'rcam_post_angle', type: '%s'}, $
            {name: 'tcam_post_angle', type: '%s'}, $
            {name: 'rcam_found_post_angle', type: '%s'}, $
            {name: 'tcam_found_post_angle', type: '%s'}, $
            {name: 'rcam_eccentricity', type: '%s'}, $
            {name: 'tcam_eccentricity', type: '%s'}, $
            {name: 'rcam_ellipse_angle', type: '%s'}, $
            {name: 'tcam_ellipse_angle', type: '%s'}, $

            {name: 'image_scale', type: '%s'}, $

            {name: 'wave_region', type: '''%s'''}, $
            {name: 'ntunes', type: '%d'}, $
            {name: 'pol_list', type: '''%s'''}, $

            {name: 'nextensions', type: '%d'}, $

            {name: 'exposure', type: '%f'}, $
            {name: 'nd', type: '%d'}, $
            {name: 'intensity', type: '%s'}, $
            {name: 'background', type: '%s'}, $

            {name: 't_base', type: '%s'}, $
            {name: 't_lcvr1', type: '%s'}, $
            {name: 't_lcvr2', type: '%s'}, $
            {name: 't_lcvr3', type: '%s'}, $
            {name: 't_lnb1', type: '%s'}, $
            {name: 't_mod', type: '%s'}, $
            {name: 't_lnb2', type: '%s'}, $
            {name: 't_lcvr4', type: '%s'}, $
            {name: 't_lcvr5', type: '%s'}, $
            {name: 't_rack', type: '%s'}, $
            {name: 'tu_base', type: '%s'}, $
            {name: 'tu_lcvr1', type: '%s'}, $
            {name: 'tu_lcvr2', type: '%s'}, $
            {name: 'tu_lcvr3', type: '%s'}, $
            {name: 'tu_lnb1', type: '%s'}, $
            {name: 'tu_mod', type: '%s'}, $
            {name: 'tu_lnb2', type: '%s'}, $
            {name: 'tu_lcvr4', type: '%s'}, $
            {name: 'tu_lcvr5', type: '%s'}, $
            {name: 'tu_rack', type: '%s'}, $
            {name: 'tu_c0arr', type: '%s'}, $
            {name: 'tu_c0pcb', type: '%s'}, $
            {name: 'tu_c1arr', type: '%s'}, $
            {name: 'tu_c1pcb', type: '%s'}, $

            {name: 'occltrid', type: '''%s'''}, $
            {name: 'o1id', type: '''%s'''}, $
            {name: 'rcamnuc', type: '''%s'''}, $
            {name: 'tcamnuc', type: '''%s'''}, $

            {name: 'flat_rcam_median_linecenter', type: '%s'}, $
            {name: 'flat_rcam_median_continuum', type: '%s'}, $
            {name: 'flat_tcam_median_linecenter', type: '%s'}, $
            {name: 'flat_tcam_median_continuum', type: '%s'}, $

            {name: 'dmodswid', type: '''%s'''}, $
            {name: 'distort', type: '''%s'''}, $

            {name: 'obsswid', type: '''%s'''}, $

            {name: 'sky_pol_factor', type: '%s'}, $
            {name: 'sky_bias', type: '%s'}, $

            {name: 'ucomp_sw_id', type: '%d'}]
  sql_cmd = string(strjoin(fields.name, ', '), $
                   strjoin(fields.type, ', '), $
                   format='(%"insert into ucomp_eng (%s) values (%s)")')

  for f = 0L, n_files - 1L do begin
    file = l0_files[f]

    mg_log, 'ingesting %s', file_basename(file.raw_filename), $
            name=logger_name, /info

    ; TODO: calculate: sky_pol_factor, sky_bias
    dmodswid = ''
    distortion = ''

    if (obj_valid(file.rcam_geometry) && obj_valid(file.tcam_geometry)) then begin
      rcam_center = file.rcam_geometry.occulter_center
      rcam_radius = file.rcam_geometry.occulter_radius
      rcam_occulter_chisq = file.rcam_geometry.occulter_chisq
      tcam_center = file.tcam_geometry.occulter_center
      tcam_radius = file.tcam_geometry.occulter_radius
      tcam_occulter_chisq = file.tcam_geometry.occulter_chisq

      rcam_radius_guess = file.rcam_geometry.radius_guess
      tcam_radius_guess = file.tcam_geometry.radius_guess
      radius_guess = mean([rcam_radius_guess, tcam_radius_guess], /nan)

      rcam_post_angle = file.rcam_geometry.post_angle
      tcam_post_angle = file.tcam_geometry.post_angle
      rcam_found_post_angle = file.rcam_geometry.found_post_angle
      tcam_found_post_angle = file.tcam_geometry.found_post_angle
      rcam_eccentricity = file.rcam_geometry.eccentricity
      tcam_eccentricity = file.tcam_geometry.eccentricity
      rcam_ellipse_angle = file.rcam_geometry.ellipse_angle
      tcam_ellipse_angle = file.tcam_geometry.ellipse_angle
    endif else begin
      rcam_center = fltarr(2) + !values.f_nan
      rcam_radius = !values.f_nan
      rcam_occulter_chisq = !values.f_nan
      tcam_center = fltarr(2) + !values.f_nan
      tcam_radius = !values.f_nan
      tcam_occulter_chisq = !values.f_nan

      radius_guess = !values.f_nan

      rcam_post_angle = !values.f_nan
      tcam_post_angle = !values.f_nan
      rcam_found_post_angle = !values.f_nan
      tcam_found_post_angle = !values.f_nan
      rcam_eccentricity = !values.f_nan
      tcam_eccentricity = !values.f_nan
      rcam_ellipse_angle = !values.f_nan
      tcam_ellipse_angle = !values.f_nan
    endelse

    db->execute, sql_cmd, $
                 file_basename(file.raw_filename), $
                 file.date_obs, $
                 obsday_index, $
                 file.obsday_hours, $
                 level_index, $

                 file.focus, $
                 ucomp_db_float(file.o1focus), $

                 file.obs_id_name, $
                 file.obs_id_version, $
                 file.obs_plan_name, $
                 file.obs_plan_version, $

                 file.cover_in, $
                 file.darkshutter_in, $
                 file.opal_in, $
                 file.polangle, $
                 file.retangle, $
                 file.caloptic_in, $

                 ucomp_db_float(rcam_center[0], valid_range=[0.0, 1279.0]), $
                 ucomp_db_float(rcam_center[1], valid_range=[0.0, 1023.0]), $
                 ucomp_db_float(rcam_radius, valid_range=[0.0, 820.0]), $
                 ucomp_db_float(rcam_occulter_chisq), $
                 ucomp_db_float(tcam_center[0], valid_range=[0.0, 1279.0]), $
                 ucomp_db_float(tcam_center[1], valid_range=[0.0, 1023.0]), $
                 ucomp_db_float(tcam_radius, valid_range=[0.0, 820.0]), $
                 ucomp_db_float(tcam_occulter_chisq), $

                 ucomp_db_float(radius_guess), $

                 ucomp_db_float(rcam_post_angle, valid_range=[-360.0, 360.0]), $
                 ucomp_db_float(tcam_post_angle, valid_range=[-360.0, 360.0]), $
                 ucomp_db_float(rcam_found_post_angle, valid_range=[-360.0, 360.0]), $
                 ucomp_db_float(tcam_found_post_angle, valid_range=[-360.0, 360.0]), $
                 ucomp_db_float(rcam_eccentricity, valid_range=[0.0, 1.0]), $
                 ucomp_db_float(tcam_eccentricity, valid_range=[0.0, 1.0]), $
                 ucomp_db_float(rcam_ellipse_angle), $
                 ucomp_db_float(tcam_ellipse_angle), $

                 ucomp_db_float(file.image_scale), $

                 file.wave_region, $
                 file.n_unique_wavelengths, $
                 file.pol_list, $

                 file.n_extensions, $

                 file.exptime, $
                 file.nd, $
                 ucomp_db_float(file.median_intensity), $
                 ucomp_db_float(file.median_background), $

                 ucomp_db_float(file.t_base, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lcvr1, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lcvr2, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lcvr3, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lnb1, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_mod, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lnb2, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lcvr4, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_lcvr5, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.t_rack, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_base, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lcvr1, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lcvr2, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lcvr3, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lnb1, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_mod, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lnb2, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lcvr4, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_lcvr5, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_rack, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_c0arr, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_c0pcb, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_c1arr, valid_range=[-20.0, 100.0]), $
                 ucomp_db_float(file.tu_c1pcb, valid_range=[-20.0, 100.0]), $

                 file.occultrid, $
                 file.o1id, $
                 file.rcamnuc, $
                 file.tcamnuc, $

                 ucomp_db_float(file.flat_rcam_median_linecenter), $
                 ucomp_db_float(file.flat_rcam_median_continuum), $
                 ucomp_db_float(file.flat_tcam_median_linecenter), $
                 ucomp_db_float(file.flat_tcam_median_continuum), $

                 dmodswid, $
                 distortion, $

                 file.obsswid, $

                 ucomp_db_float(sky_pol_factor), $
                 ucomp_db_float(sky_bias), $

                 sw_index, $
                 status=status
  endfor

  done:
end
