; docformat = 'rst'

;+
; Insert an array of L0 FITS files into the ucomp_eng database table.
;
; :Params:
;   l0_files : in, required, type=strarr
;     array of `UCOMP_FILE` objects
;   obsday_index : in, required, type=integer
;     index into mlso_numfiles database table
;   database : in, optional, type=object
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

  for f = 0L, n_files - 1L do begin
    file = l0_files[f]

    mg_log, 'ingesting %s', file_basename(file.raw_filename), $
            name=logger_name, /info

    ; TODO: calculate: sky_pol_factor, sky_bias
    dmodswid = ''
    distortion = ''

    fields = [{name: 'file_name', type: '''%s'''}, $
              {name: 'date_obs', type: '''%s'''}, $
              {name: 'obsday_id', type: '%d'}, $
              {name: 'level_id', type: '%d'}, $

              {name: 'focus', type: '%f'}, $
              {name: 'o1focus', type: '%s'}, $

              {name: 'obs_id', type: '''%s'''}, $
              {name: 'obs_plan', type: '''%s'''}, $

              {name: 'cover', type: '%d'}, $
              {name: 'darkshutter', type: '%d'}, $
              {name: 'opal', type: '%d'}, $
              {name: 'polangle', type: '%f'}, $
              {name: 'retangle', type: '%f'}, $
              {name: 'caloptic', type: '%d'}, $

              {name: 'ixcnter1', type: '%s'}, $
              {name: 'iycnter1', type: '%s'}, $
              {name: 'iradius1', type: '%s'}, $
              {name: 'ixcnter2', type: '%s'}, $
              {name: 'iycnter2', type: '%s'}, $
              {name: 'iradius2', type: '%s'}, $

              {name: 'overlap_angle', type: '%s'}, $
              {name: 'post_angle', type: '%s'}, $

              {name: 'wave_region', type: '''%s'''}, $
              {name: 'ntunes', type: '%d'}, $
              {name: 'pol_list', type: '''%s'''}, $

              {name: 'nextensions', type: '%d'}, $

              {name: 'exposure', type: '%f'}, $
              {name: 'nd', type: '%d'}, $
              {name: 'background', type: '%s'}, $

              {name: 't_fw', type: '%s'}, $
              {name: 't_lcvr1', type: '%s'}, $
              {name: 't_lcvr2', type: '%s'}, $
              {name: 't_lcvr3', type: '%s'}, $
              {name: 't_lnb1', type: '%s'}, $
              {name: 't_mod', type: '%s'}, $
              {name: 't_lnb2', type: '%s'}, $
              {name: 't_lcvr4', type: '%s'}, $
              {name: 't_lcvr5', type: '%s'}, $
              {name: 't_rack', type: '%s'}, $
              {name: 'tu_fw', type: '%s'}, $
              {name: 'tu_lcvr1', type: '%s'}, $
              {name: 'tu_lcvr2', type: '%s'}, $
              {name: 'tu_lcvr3', type: '%s'}, $
              {name: 'tu_lnb1', type: '%s'}, $
              {name: 'tu_mod', type: '%s'}, $
              {name: 'tu_lnb2', type: '%s'}, $
              {name: 'tu_lcvr4', type: '%s'}, $
              {name: 'tu_lcvr5', type: '%s'}, $
              {name: 'tu_rack', type: '%s'}, $
              {name: 't_c0arr', type: '%s'}, $
              {name: 't_c0pcb', type: '%s'}, $
              {name: 't_c1arr', type: '%s'}, $
              {name: 't_c1pcb', type: '%s'}, $

              {name: 'occltrid', type: '''%s'''}, $

              {name: 'dmodswid', type: '''%s'''}, $
              {name: 'distort', type: '''%s'''}, $

              {name: 'obsswid', type: '''%s'''}, $

              {name: 'sky_pol_factor', type: '%s'}, $
              {name: 'sky_bias', type: '%s'}, $

              {name: 'ucomp_sw_id', type: '%d'}]
    sql_cmd = string(strjoin(fields.name, ', '), $
                     strjoin(fields.type, ', '), $
                     format='(%"insert into ucomp_eng (%s) values (%s)")')
    db->execute, sql_cmd, $
                 file_basename(file.raw_filename), $
                 file.date_obs, $
                 obsday_index, $
                 level_index, $

                 file.focus, $
                 ucomp_db_float(file.o1focus), $

                 file.obs_id, $
                 file.obs_plan, $

                 file.cover_in, $
                 file.darkshutter_in, $
                 file.opal_in, $
                 file.polangle, $
                 file.retangle, $
                 file.caloptic_in, $

                 ucomp_db_float(file.ixcnter1), $
                 ucomp_db_float(file.iycnter1), $
                 ucomp_db_float(file.iradius1), $
                 ucomp_db_float(file.ixcnter2), $
                 ucomp_db_float(file.iycnter2), $
                 ucomp_db_float(file.iradius2), $

                 ucomp_db_float(file.overlap_angle), $
                 ucomp_db_float(file.post_angle), $

                 file.wave_region, $
                 file.n_unique_wavelengths, $
                 file.pol_list, $

                 file.n_extensions, $

                 file.exptime, $
                 file.nd, $
                 ucomp_db_float(background), $

                 ucomp_db_float(file.t_fw), $
                 ucomp_db_float(file.t_lcvr1), $
                 ucomp_db_float(file.t_lcvr2), $
                 ucomp_db_float(file.t_lcvr3), $
                 ucomp_db_float(file.t_lnb1), $
                 ucomp_db_float(file.t_mod), $
                 ucomp_db_float(file.t_lnb2), $
                 ucomp_db_float(file.t_lcvr4), $
                 ucomp_db_float(file.t_lcvr5), $
                 ucomp_db_float(file.t_rack), $
                 ucomp_db_float(file.tu_fw), $
                 ucomp_db_float(file.tu_lcvr1), $
                 ucomp_db_float(file.tu_lcvr2), $
                 ucomp_db_float(file.tu_lcvr3), $
                 ucomp_db_float(file.tu_lnb1), $
                 ucomp_db_float(file.tu_mod), $
                 ucomp_db_float(file.tu_lnb2), $
                 ucomp_db_float(file.tu_lcvr4), $
                 ucomp_db_float(file.tu_lcvr5), $
                 ucomp_db_float(file.tu_rack), $
                 ucomp_db_float(file.t_c0arr), $
                 ucomp_db_float(file.t_c0pcb), $
                 ucomp_db_float(file.t_c1arr), $
                 ucomp_db_float(file.t_c1pcb), $

                 file.occultrid, $

                 dmodswid, $
                 distortion, $

                 file.obsswid, $

                 ucomp_db_float(sky_pol_factor), $
                 ucomp_db_float(sky_bias), $

                 sw_index, $
                 sql_statement=sql_statement, status=status, error_message=error_message
    mg_log, sql_statement, name=logger_name, /debug
    mg_log, error_message, name=logger_name, /debug
    mg_log, 'status: %d', status, name=logger_name, /debug
  endfor

  done:
end
